// book_service.dart
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'models.dart';

class BookService {
  // ANDROID EMULATOR FIX
  static const String _baseUrl = 'http://192.168.0.9:3000';

  Future<PageModel> parseHtmlCss({
    required String html,
    required String css,
  }) async {
    log("currently in parseHtml with url ${_baseUrl}");
    final response = await http.post(
      Uri.parse('$_baseUrl/parse'),
      headers: {'Content-Type': 'application/json'},
    );
    log("send request");
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final decoded = jsonDecode(response.body);
    log(response.body);
    return PageModel.fromJson(decoded);
  }
}
