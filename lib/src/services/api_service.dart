import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/routix_match.dart';

class ApiService {
  final String apiKey;
  final String sdkVersion;

  ApiService({
    required this.apiKey,
    required this.sdkVersion,
  });

  static const String baseUrl = 'https://api.routix.link';

  Future<RoutixMatch?> resolve(String? token, Map<String, dynamic> deviceInfo) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/v1/sdk/resolve'),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': apiKey,
              'X-SDK-Version': sdkVersion,
            },
            body: jsonEncode({
              'install_referrer': token,
              'device_info': deviceInfo,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return RoutixMatch.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      // Log or handle error
    }
    return null;
  }

  Future<bool> trackLinkEvent(
      String code, String endpoint, Map<String, dynamic>? data) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/v1/links/$code/$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': apiKey,
            },
            body: jsonEncode({
              ...(data ?? {}),
              'sdk_v': sdkVersion,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> trackCustomEvent(
      String eventType, Map<String, dynamic>? data) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/v1/track'),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': apiKey,
            },
            body: jsonEncode({
              'event_type': eventType,
              ...(data ?? {}),
              'sdk_v': sdkVersion,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
