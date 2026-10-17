class OperatorProfile {
  final String fullName;
  final String region;
  final DateTime createdAt;

  OperatorProfile({
    required this.fullName,
    required this.region,
    required this.createdAt,
  });

  factory OperatorProfile.fromJson(Map<String, dynamic> j) {
    return OperatorProfile(
      fullName: j['full_name'] as String? ?? '',
      region: j['region'] as String? ?? '',
      createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
    );
  }
}
