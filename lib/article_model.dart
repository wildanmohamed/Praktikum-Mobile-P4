
class Article {
  final String title;
  final String? description;
  final String? urlToImage;
  final String? sourceName;

  Article({
    required this.title,
    this.description,
    this.urlToImage,
    this.sourceName,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title']?.toString() ?? 'Judul tidak tersedia',
      description: json['description']?.toString(),
      urlToImage: json['urlToImage']?.toString(),
      sourceName: json['source'] is Map
          ? json['source']['name']?.toString()
          : null,
    );
  }
}
