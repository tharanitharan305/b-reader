import 'package:flutter/material.dart';

class Searchbook extends StatelessWidget {
  final Function(String) onSearch;
  const Searchbook({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black12),
      ),
      width: size.width,
      height: 50,
      child: TextField(
        onChanged: onSearch,
        decoration: const InputDecoration(
          hintText: "Search",
          prefixIcon: Icon(Icons.search, size: 28),
          border: InputBorder.none, // This removes the underline
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}
