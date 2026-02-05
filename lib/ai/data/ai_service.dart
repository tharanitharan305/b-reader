import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class SummarizeService {
  static const _baseUrl =
      'https://apidev.cloud/ai/api/v1/summarize';

  final http.Client client;

  SummarizeService({required this.client});

  Future<Map<String, dynamic>> summarize(
      Map<String, dynamic> body) async {
    final response = await client.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
log(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Summarize API failed: ${response.statusCode}',

      );
    }


  }
}
