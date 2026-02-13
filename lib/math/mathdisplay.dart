import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_math_fork/flutter_math.dart';

enum LanguageMode { both, english, tamil }
enum ContentType { definitions, formulas }

class LatexViewerPage extends StatefulWidget {
  const LatexViewerPage({super.key});

  @override
  State<LatexViewerPage> createState() => _LatexViewerPageState();
}

class _LatexViewerPageState extends State<LatexViewerPage> {
  List<dynamic> definitions = [];
  List<dynamic> formulas = [];

  bool isLoading = true;
  String searchQuery = "";

  LanguageMode languageMode = LanguageMode.both;
  ContentType contentType = ContentType.definitions;

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  // ================= API =================

  Future<void> fetchAllData() async {
    try {
      final defRes =
      await http.get(Uri.parse('https://apidev.cloud/api/api/content'));

      final formulaRes =
      await http.get(Uri.parse('https://apidev.cloud/api/api/formulas'));

      setState(() {
        definitions = jsonDecode(defRes.body)['data'];
        formulas = jsonDecode(formulaRes.body)['data'];
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= LANGUAGE =================

  void toggleLanguage() {
    setState(() {
      languageMode = LanguageMode
          .values[(languageMode.index + 1) % LanguageMode.values.length];
    });
  }

  String getLanguageLabel() {
    switch (languageMode) {
      case LanguageMode.both:
        return "EN + TA";
      case LanguageMode.english:
        return "EN";
      case LanguageMode.tamil:
        return "TA";
    }
  }

  // ================= LATEX =================

  Widget buildLatexText(String text, {bool isTamil = false}) {
    final regex = RegExp(r'\$(.*?)\$');
    List<InlineSpan> spans = [];
    int lastIndex = 0;

    final style = TextStyle(
      fontSize: 16,
      fontFamily: isTamil ? 'Simon' : null,
      height: isTamil ? 1.8 : 1.4,
      color: Colors.black,
    );

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
            text: text.substring(lastIndex, match.start), style: style));
      }

      spans.add(const TextSpan(text: " "));

      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Math.tex(match.group(1)!,
            textStyle: const TextStyle(fontSize: 18)),
      ));

      spans.add(const TextSpan(text: " "));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: style));
    }

    return RichText(text: TextSpan(children: spans));
  }

  // ================= SEARCH =================

  bool matchesSearch(dynamic item) {
    final keywordList =
    (item['searchable_keywords'] ?? []).join(" ").toLowerCase();

    final nameEN = item['name']['EN'].toLowerCase();

    return keywordList.contains(searchQuery.toLowerCase()) ||
        nameEN.contains(searchQuery.toLowerCase());
  }

  List<dynamic> get filteredList {
    final source =
    contentType == ContentType.definitions ? definitions : formulas;

    if (searchQuery.isEmpty) return source;

    return source.where(matchesSearch).toList();
  }

  // ================= CARD =================

  Widget buildCard(dynamic item) {
    final isFormula = contentType == ContentType.formulas;

    final englishText =
    isFormula ? item['formula']['EN'] : item['content']['EN'];

    final tamilText =
    isFormula ? item['formula']['TA'] : item['content']['TA'];

    final keywords =
    (item['searchable_keywords'] ?? []).join(", ");

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (languageMode != LanguageMode.tamil)
              Text(item['name']['EN'],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),

            if (languageMode == LanguageMode.both)
              const SizedBox(height: 6),

            if (languageMode != LanguageMode.english)
              Text(item['name']['TA'],
                  style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Simon',
                      height: 1.8,
                      fontWeight: FontWeight.w500)),

            const SizedBox(height: 10),

            if (languageMode != LanguageMode.tamil)
              buildLatexText(englishText),

            if (languageMode == LanguageMode.both)
              const SizedBox(height: 10),

            if (languageMode != LanguageMode.english)
              buildLatexText(tamilText, isTamil: true),

            const SizedBox(height: 10),

            Text("Keywords: $keywords",
                style: const TextStyle(
                    fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Math Viewer"),
        actions: [
          TextButton(
            onPressed: toggleLanguage,
            child: Text(getLanguageLabel(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // ===== TAB BUTTONS =====
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(
                          () => contentType = ContentType.definitions),
                  child: const Text("Definitions"),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(
                          () => contentType = ContentType.formulas),
                  child: const Text("Formulas"),
                ),
              ),
            ],
          ),

          // ===== SEARCH =====
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) =>
                  setState(() => searchQuery = value),
            ),
          ),

          // ===== LIST =====
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredList.length,
              itemBuilder: (_, i) => buildCard(filteredList[i]),
            ),
          ),
        ],
      ),
    );
  }
}
