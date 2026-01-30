// book_service.dart
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'models.dart';

class BookService {
  // ANDROID EMULATOR FIX
  static const String _baseUrl = 'http://192.168.0.10:3000';

  Future<PageModel> parseHtmlCss({
    required String html,
    required String css,
  }) async {
    try{
      log("started parse");
      final book ="book3";
      final url=Uri.parse('$_baseUrl/getbookin/$book');
      log("currently in parseHtml with url ${url}");
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      log("send request");
      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      final decoded = jsonDecode(response.body);
      return PageModel.fromJson(decoded);
    } catch(e){
      print(e.toString());
      print((e as Error ).stackTrace);
    }
    return PageModel(version: '', book: BookModel(pages: []), bookName: '');
  }

}
