class StoreItemModel {
  final String id;
  final String category; // starlink | device
  final String name;
  final String subtitle;
  final double price;
  final String currency;

  StoreItemModel({
    required this.id,
    required this.category,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.currency,
  });

  factory StoreItemModel.fromJson(Map<String, dynamic> j) {
    return StoreItemModel(
      id: j['id'] as String,
      category: j['category'] as String? ?? 'device',
      name: j['name'] as String,
      subtitle: j['subtitle'] as String? ?? '',
      price: (j['price'] as num).toDouble(),
      currency: j['currency'] as String? ?? 'USD',
    );
  }

  String get priceLabel => currency == 'USD' ? '${price.toStringAsFixed(0)} \$' : '${price.toStringAsFixed(0)} $currency';
}
