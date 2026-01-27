class Book {
  String id;
  String version;
  String image_url;
  String title;
  Book({required this.id,required this.version,required this.image_url,required this.title});
  factory Book.fromJson(Map<String,dynamic> json){

return Book(id: "",image_url: json['image'],title: json['title'],version: json['version']);





  }
}