class RoutixMatch {
  final bool success;
  final String? shortCode;
  final String? originalUrl;
  final String? matchSource; // 'referrer', 'fingerprint', 'clipboard'
  final double? confidence; // 0.0 to 1.0
  final Map<String, dynamic>? metadata;
  final DateTime? timestamp;

  RoutixMatch({
    required this.success,
    this.shortCode,
    this.originalUrl,
    this.matchSource,
    this.confidence,
    this.metadata,
    this.timestamp,
  });

  factory RoutixMatch.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] is Map ? json['metadata'] as Map<String, dynamic> : null;
    return RoutixMatch(
      success: json['success'] ?? false,
      shortCode: json['short_code'],
      originalUrl: json['original_url'] ?? meta?['original_url'],
      matchSource: json['attribution_source'] ?? json['match_type'] ?? json['match_source'],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      metadata: meta,
      timestamp: json['timestamp'] != null 
          ? DateTime.tryParse(json['timestamp']) 
          : null,
    );
  }

  @override
  String toString() {
    return 'RoutixMatch(success: $success, code: $shortCode, type: $matchSource)';
  }
}
