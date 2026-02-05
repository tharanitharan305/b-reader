class Book {
  String id;
  String version;
  String image_url;
  String title;
  bool isDownloaded;
  bool isFromServer;

  Book({
    required this.id,
    required this.version,
    required this.image_url,
    required this.title,
    this.isDownloaded = false,
    this.isFromServer = true,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? "",
      image_url: json['image'] ?? json['image_url'] ?? "",
      title: json['title'] ?? "",
      version: json['version'] ?? "",
    );
  }
}
