import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'src/models/routix_match.dart';
export 'src/models/routix_match.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/services/api_service.dart';
import 'src/services/device_service.dart';

class Routix {
  static const String _version = '1.0.4';
  static const MethodChannel _channel = MethodChannel('link.routix.sdk/internal');
  
  static String? _apiKey;
  static ApiService? _api;

  /// Global stream for attribution events.
  static final StreamController<RoutixMatch> _attributionController = StreamController<RoutixMatch>.broadcast();
  static Stream<RoutixMatch> get onAttribution => _attributionController.stream;

  /// Set to true to enable debug logging.
  static bool debugMode = false;
  
  Routix._();

  static void initialize({required String apiKey}) {
    _apiKey = apiKey;
    _api = ApiService(
      apiKey: _apiKey!,
      sdkVersion: 'flutter-$_version',
    );
  }

  /// Parses a direct deep link URL when the app is already installed.
  /// 
  /// Returns a [RoutixMatch] if it's a valid Routix link (contains code or ref param), 
  /// otherwise returns null. This happens locally without hitting the network.
  static RoutixMatch? handleDeepLink(String url) {
    try {
      final uri = Uri.parse(url);
      final shortCode = uri.queryParameters['code'] ?? uri.queryParameters['ref'];
      
      if (shortCode == null) return null;

      final match = RoutixMatch(
        success: true,
        shortCode: shortCode,
        originalUrl: url,
        matchSource: 'direct_link',
        confidence: 1.0,
        timestamp: DateTime.now().toUtc(),
      );

      _attributionController.add(match);
      return match;
    } catch (e) {
      return null;
    }
  }

  /// Resolves the deep link attribution for this installation.
  /// 
  /// [enableClipboard] (default: false) will check the iOS/Android clipboard 
  /// for a fallback token. Note: This may trigger a "Pasted from..." popup on iOS 14+.
  static Future<RoutixMatch?> resolve({bool enableClipboard = false}) async {
    if (_api == null) throw Exception('Routix SDK not initialized. Call initialize() first.');

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('routix_resolved') == true) return null;

    try {
      String? referrer;
      String? clipboardToken;

      // 1. Android Install Referrer (Deterministic)
      if (Platform.isAndroid) {
          try {
            referrer = await _channel.invokeMethod('getInstallReferrer');
          } catch (e) {
            if (debugMode) print('[Routix] Referrer error: $e');
          }
      }

      // 2. Clipboard Fallback (iOS / Manual Fallback)
      if (enableClipboard) {
        try {
          final data = await Clipboard.getData(Clipboard.kTextPlain);
          if (data?.text != null && data!.text!.startsWith('rtx_')) {
             // Strip the rtx_ prefix to get the clean UUID
             clipboardToken = data.text!.substring(4);
          }
        } catch (e) {
          if (debugMode) print('[Routix] Clipboard error: $e');
        }
      }

      // Use whichever token we found (Referrer has priority)
      final effectiveToken = referrer ?? clipboardToken;

      final deviceInfo = await DeviceService.getDeviceInfo();
      final match = await _api!.resolve(effectiveToken, deviceInfo);
      
      if (match != null && match.success) {
        await prefs.setBool('routix_resolved', true);
        _attributionController.add(match);
      }
      return match;
    } catch (e) {
      if (debugMode) print('[Routix] resolve() failed: $e');
    }
    return null;
  }

  static Future<bool> _trackInternal(String code, {
    String type = 'custom', 
    Map<String, dynamic>? metadata
  }) async {
    if (_api == null) return false;

    String endpoint = 'track';
    if (type == 'install') endpoint = 'install';
    if (type == 'lead') endpoint = 'lead';
    if (type == 'sale') endpoint = 'sale';

    return _api!.trackLinkEvent(code, endpoint, metadata);
  }

  static Future<bool> trackInstall(String code) => _trackInternal(code, type: 'install');
  static Future<bool> trackLead(String code, {Map<String, dynamic>? metadata}) => _trackInternal(code, type: 'lead', metadata: metadata);
  
  /// Tracks a revenue event attributed to a specific link.
  static Future<bool> trackSale(String code, {
    required double amount, 
    required String currency, 
    Map<String, dynamic>? metadata
  }) => 
    _trackInternal(code, type: 'sale', metadata: { ...?metadata, 'amount': amount, 'currency': currency });

  /// Tracks a custom event attributed to a specific link.
  static Future<bool> trackLinkEvent(String code, String eventType, {Map<String, dynamic>? metadata}) =>
    _trackInternal(code, type: 'track', metadata: { ...?metadata, 'event_type': eventType });

  /// Tracks a workspace-level custom event independent of any link.
  static Future<bool> trackCustomEvent(String eventType, {Map<String, dynamic>? metadata}) async {
    if (_api == null) return false;
    return _api!.trackCustomEvent(eventType, metadata);
  }
}
