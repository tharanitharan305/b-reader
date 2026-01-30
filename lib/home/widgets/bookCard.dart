import 'package:btab/book_ui.dart';
import 'package:flutter/material.dart';

import '../data/book.dart';

class Bookcard extends StatelessWidget {
  Book b;
  Function (String) onNav;
  Bookcard({required this.b,required this.onNav});

  Widget inside(Book b, context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          padding: EdgeInsets.only(top: 40,left: 40,right: 40),
          child: Image.asset("assets/images/book1.png", fit: BoxFit.fitHeight),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: -35,
              ),
            ],
          ),
        ),
        Text(
          b.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: BoxBorder.all(color: Colors.black),
          ),
          child: TextButton.icon(
            onPressed:(){
              onNav(b.title);
            },
            label: Text(
              "Learn",
              style: TextStyle(fontSize: 24, color: Colors.black54),
            ),
            icon: Icon(Icons.arrow_forward_ios_rounded),
            iconAlignment: IconAlignment.end,
            style: TextButton.styleFrom(minimumSize: Size(208, 44)),
          ),
        ),
        SizedBox(height: 5),
      ],
    );
  }

  Widget build(context) {
    print("in book card with a book name of ${b.title}");
    return GestureDetector(
      onTap: (){
        onNav(b.title);
      },
      child: Container(
        height: 472,
        width: 288,
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 245, 244, 1),
          borderRadius: BorderRadius.circular(20),
          border: BoxBorder.all(color: Colors.black12),
        ),
        child: inside(b, context),
      ),
    );
  }
}
