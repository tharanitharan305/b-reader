import 'package:btab/book_ui.dart';
import 'package:flutter/material.dart';

import '../data/book.dart';

class Bookcard extends StatelessWidget {
  Book b;
  Bookcard({required this.b});
  Widget inside(Book b,context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly
    ,children: [
     Container(padding: EdgeInsets.all(40),child:  Image.network(b.image_url,), decoration: BoxDecoration(boxShadow:[BoxShadow(color: Colors.black12,blurRadius: 10,spreadRadius: -35)] ),),
      Text(b.title,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
     Container( decoration:BoxDecoration(borderRadius: BorderRadius.circular(5),border: BoxBorder.all(color: Colors.black)),child: TextButton.icon(onPressed: (){
       Navigator.push(context, MaterialPageRoute(builder: (context) => BookEditorScreen(),));
     }, label: Text("Learn",style: TextStyle(fontSize:24 ,color: Colors.black54),),icon: Icon(Icons.arrow_forward_ios_rounded),iconAlignment: IconAlignment.end,style: TextButton.styleFrom(minimumSize: Size(208, 44)),))
    ],);
  }
  Widget build(context){
    print("in book card with a book name of ${b.title}");
    return Container(
     height: 462,
        width: 288,
      decoration: BoxDecoration(color: Colors.amber.shade50,borderRadius: BorderRadius.circular(20),border: BoxBorder.all(color: Colors.black12           )),
      child: inside(b,context),
    );
  }
}