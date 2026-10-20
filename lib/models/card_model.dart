class CardModel {
  final String id;
  final String packageId;
  final String code;
  final String status; // unused | sold | used
  final DateTime createdAt;
  final String? packageName;
  final int? packageDurationDays;

  CardModel({
    required this.id,
    required this.packageId,
    required this.code,
    required this.status,
    required this.createdAt,
    this.packageName,
    this.packageDurationDays,
  });

  DateTime? get expiresAt =>
      packageDurationDays == null ? null : createdAt.add(Duration(days: packageDurationDays!));

  factory CardModel.fromJson(Map<String, dynamic> j) {
    final package = j['package'] as Map<String, dynamic>?;
    return CardModel(
      id: j['id'] as String,
      packageId: j['package_id'] as String,
      code: j['code'] as String,
      status: j['status'] as String? ?? 'unused',
      createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
      packageName: package?['name'] as String?,
      packageDurationDays: package?['duration_days'] as int?,
    );
  }
}
