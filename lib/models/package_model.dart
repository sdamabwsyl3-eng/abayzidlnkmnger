class PackageModel {
  final String id;
  final String name;
  final String subtitle;
  final int durationDays;
  final double price;
  final String currency;

  PackageModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.durationDays,
    required this.price,
    required this.currency,
  });

  factory PackageModel.fromJson(Map<String, dynamic> j) {
    return PackageModel(
      id: j['id'] as String,
      name: j['name'] as String,
      subtitle: j['subtitle'] as String? ?? '',
      durationDays: j['duration_days'] as int? ?? 30,
      price: (j['price'] as num).toDouble(),
      currency: j['currency'] as String? ?? 'SDG',
    );
  }

  String get priceLabel => '${price.toStringAsFixed(0)} $currency';
}
