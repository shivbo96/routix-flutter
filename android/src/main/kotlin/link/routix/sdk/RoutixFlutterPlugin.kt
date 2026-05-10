package link.routix.sdk

import android.content.Context
import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.atomic.AtomicBoolean

/** RoutixFlutterPlugin */
class RoutixFlutterPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "link.routix.sdk/internal")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getInstallReferrer") {
            getReferrer(result)
        } else {
            result.notImplemented()
        }
    }

    private fun getReferrer(result: Result) {
        // Guard against result being replied to multiple times.
        // Some OEM devices fire both onInstallReferrerSetupFinished AND
        // onInstallReferrerServiceDisconnected, which would cause an IllegalStateException crash.
        val resultSent = AtomicBoolean(false)

        val referrerClient = InstallReferrerClient.newBuilder(context).build()
        referrerClient.startConnection(object : InstallReferrerStateListener {
            override fun onInstallReferrerSetupFinished(responseCode: Int) {
                if (!resultSent.compareAndSet(false, true)) return
                try {
                    when (responseCode) {
                        InstallReferrerClient.InstallReferrerResponse.OK -> {
                            val referrerUrl = referrerClient.installReferrer.installReferrer
                            result.success(referrerUrl)
                        }
                        InstallReferrerClient.InstallReferrerResponse.FEATURE_NOT_SUPPORTED ->
                            result.error("NOT_SUPPORTED", "Install Referrer not supported on this device", null)
                        InstallReferrerClient.InstallReferrerResponse.SERVICE_UNAVAILABLE ->
                            result.error("UNAVAILABLE", "Could not connect to Play Store referrer service", null)
                        else ->
                            result.error("UNKNOWN", "Unknown error fetching install referrer", null)
                    }
                } catch (e: Exception) {
                    result.error("REFERRER_ERROR", e.message, null)
                } finally {
                    referrerClient.endConnection()
                }
            }

            override fun onInstallReferrerServiceDisconnected() {
                // Fire only if onInstallReferrerSetupFinished hasn't already replied
                if (resultSent.compareAndSet(false, true)) {
                    result.error("DISCONNECTED", "Referrer service disconnected before responding", null)
                }
            }
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
