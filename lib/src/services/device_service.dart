import 'dart:io';
import 'dart:ui';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceService {
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    final prefs = await SharedPreferences.getInstance();

    // 1. Get or Generate Anonymous Device ID
    String? deviceId = prefs.getString('routix_anon_id');
    if (deviceId == null) {
      deviceId = _generateRandomId();
      await prefs.setString('routix_anon_id', deviceId);
    }

    // 2. Get or Set First Open Timestamp
    String? firstOpen = prefs.getString('routix_first_open');
    if (firstOpen == null) {
      firstOpen = DateTime.now().toUtc().toIso8601String();
      await prefs.setString('routix_first_open', firstOpen);
    }

    final window = PlatformDispatcher.instance.views.first;
    
    Map<String, dynamic> info = {
      'app_id': packageInfo.packageName,
      'app_version': packageInfo.version,
      'build_number': packageInfo.buildNumber,
      'os': Platform.isAndroid ? 'android' : 'ios',
      'os_version': Platform.operatingSystemVersion,
      'locale': Platform.localeName,
      'timezone': DateTime.now().timeZoneName,
      'screen_width': window.physicalSize.width / window.devicePixelRatio,
      'screen_height': window.physicalSize.height / window.devicePixelRatio,
      'anonymous_device_id': deviceId,
      'first_open_timestamp': firstOpen,
    };

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      info.addAll({
        'model': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
        'os_version': androidInfo.version.release, // cleaner version
      });
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      info.addAll({
        'model': iosInfo.utsname.machine,
        'manufacturer': 'Apple',
        'os_version': iosInfo.systemVersion,
      });
    }
    
    return info;
  }

  static String _generateRandomId() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return values.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  }
}
