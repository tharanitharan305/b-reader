import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../models.dart';
import 'book.dart';

class HomeServices {
  static final String? _baseUrl = dotenv.env['BASEURL']??"http://192.168.0.10:3000";

  Future<List<Book>> getBooks() async {
    print(dotenv.env);
    log("getBooks(service): fetching books from $_baseUrl/getbooks");
    final url = Uri.parse('$_baseUrl/getbooks');
    try {
      final response = await http.get(url);
      log("getBooks(service): status code ${response.statusCode}");
      
      if (response.statusCode != 200) {
        log("getBooks(service): error response body: ${response.body}");
        throw Exception(response.body);
      }
      
      final map = jsonDecode(response.body) as List;
      List<Book> returnMap = map.map((e) {
        final book = Book.fromJson(e as Map<String, dynamic>);
        return book;
      }).toList();
      
      log("getBooks(service): successfully parsed ${returnMap.length} books");
      return returnMap;
    } catch (e) {
      log("getBooks(service): exception occurred: ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  Future<PageModel> getBook(String title) async {
    log("getBook(service): fetching book '$title' from $_baseUrl/getbook/$title");
    final url = Uri.parse('$_baseUrl/getbook/$title');
    try {
      final response = await http.get(url);
      log("getBook(service): status code ${response.statusCode}");

      if (response.statusCode != 200) {
        log("getBook(service): error response body: ${response.body}");
        throw Exception(response.body);
      }
      
      final map = jsonDecode(response.body);
      final pageModel = PageModel.fromJson(map);
      log("getBook(service): successfully parsed PageModel for '$title'");
      return pageModel;
    } catch (e) {
      log("getBook(service): exception occurred: ${e.toString()}");
      throw Exception(e.toString());
    }
  }
}
