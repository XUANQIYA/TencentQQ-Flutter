class NewsModel {
  final String id;
  final String ctime;
  final String title;
  final String description;
  final String source;
  final String picUrl;
  final String url;

  NewsModel({
    required this.id,
    required this.ctime,
    required this.title,
    required this.description,
    required this.source,
    required this.picUrl,
    required this.url,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? '',
      ctime: json['ctime'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      source: json['source'] ?? '',
      picUrl: json['picUrl'] ?? '',
      url: json['url'] ?? '',
    );
  }
}