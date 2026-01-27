import 'dart:convert';

import 'package:http/http.dart' as http;

import 'book.dart';

class HomeServices {
  String _baseUrl='http://192.168.0.5:3000';
  Future<Book> getBooks() async{
    final url=Uri.parse('$_baseUrl/getbooks');
    final response=await http.get(url);
    try{
      if(response.statusCode!=200){
          throw Exception(response.body);
      }
      final map=jsonDecode(response.body);
      return Book.fromJson(map[0]);
    }catch( e){
      throw Exception(e.toString());
    }
  }
}