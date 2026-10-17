class CardModel {
  final String id;
  final String packageId;
  final String code;
  final String status; // unused | sold | used
  final DateTime createdAt;

  CardModel({
    required this.id,
    required this.packageId,
    required this.code,
    required this.status,
    required this.createdAt,
  });

  factory CardModel.fromJson(Map<String, dynamic> j) {
    return CardModel(
      id: j['id'] as String,
      packageId: j['package_id'] as String,
      code: j['code'] as String,
      status: j['status'] as String? ?? 'unused',
      createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
    );
  }
}
