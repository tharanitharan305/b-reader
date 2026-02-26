import 'dart:convert';
import 'package:btab/book_ui.dart';
import 'package:btab/home/data/home_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Junior extends StatefulWidget {
  const Junior({super.key});

  @override
  State<Junior> createState() => _JuniorState();
}

class _JuniorState extends State<Junior> {
  Future<dynamic>? bookFuture;

  Future<dynamic> getBook(String id) async {
    final book = await HomeServices().getBooktest(id);
    return book;
  }

  Future<void> generateAndLoadBook() async {
    final uri = Uri.parse("http://192.168.0.13:8797/new");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final id = jsonData['id']; // 👈 backend returns id only

      setState(() {
        bookFuture = getBook(id.toString());
      });
    } else {
      print("Failed to generate book");
    }
  }

  @override
  void initState() {
    super.initState();
    generateAndLoadBook(); // load first time
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: generateAndLoadBook,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: FutureBuilder(
        future: bookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No Data Found"));
          }

          return BookEditorScreen(
            pageModel: snapshot.data,
          );
        },
      ),
    );
  }
}
