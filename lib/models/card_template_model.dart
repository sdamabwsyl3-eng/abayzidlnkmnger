class CardTemplate {
  final String id;
  final String name;
  final String? thumbnailUrl;

  CardTemplate({required this.id, required this.name, this.thumbnailUrl});

  factory CardTemplate.fromJson(Map<String, dynamic> j) {
    return CardTemplate(
      id: j['id'] as String,
      name: j['name'] as String,
      thumbnailUrl: j['thumbnail_url'] as String?,
    );
  }
}
