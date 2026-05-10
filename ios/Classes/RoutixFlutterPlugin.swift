import Flutter
import UIKit

/// iOS stub plugin for the Routix Flutter SDK.
///
/// iOS attribution is handled entirely server-side via device fingerprinting and
/// clipboard token fallback — no native iOS code is required for the MethodChannel.
/// This class exists solely to satisfy the Flutter plugin registration contract
/// and prevent build failures on iOS.
public class RoutixFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "link.routix.sdk/internal",
            binaryMessenger: registrar.messenger()
        )
        let instance = RoutixFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // All MethodChannel calls originate from Platform.isAndroid guards in Dart.
        // iOS will never send a method call to this channel under normal operation.
        result(FlutterMethodNotImplemented)
    }
}
