import 'package:flutter/material.dart';
import '../../download_engine/bloc/download_bloc.dart';
import '../data/book.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class Bookcard extends StatelessWidget {
  final Book b;
  final Function(String) onNav;
  final Function(String)? onDel;
  final Color? cardColor;

  const Bookcard({
    super.key,
    required this.b,
    required this.onNav,
    this.onDel,
    this.cardColor,
  });

  Widget inside(Book b, context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 40, left: 40, right: 40),
          child: Image.asset("assets/images/book1.png", fit: BoxFit.fitHeight),
          decoration: const BoxDecoration(
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.black),
          ),
          child: TextButton.icon(
            onPressed: () {
              onNav(b.title);
            },
            label: const Text(
              "Learn",
              style: TextStyle(fontSize: 24, color: Colors.black54),
            ),
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            iconAlignment: IconAlignment.end,
            style: TextButton.styleFrom(minimumSize: const Size(208, 44)),
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DownloadBloc, DownloadState>(
      listener: (context, state) {
        if (state is DownloadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.bookName)),
          );
        }

        if (state is DownloadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage)),
          );
        }
      },
      child: GestureDetector(
        onTap: () {
          onNav(b.title);
        },
        onLongPress: () async {
          if (onDel == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Can't delete — book not downloaded")),
            );
            return;
          }

          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Delete Book"),
              content: const Text("Are you sure you want to delete this book?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );

          if (confirm == true) {
            context.read<DownloadBloc>().add(DeleteBook(b.title));
          }
        },

        child: Container(
          height: 472,
          width: 288,
          decoration: BoxDecoration(
            color: cardColor ?? const Color.fromRGBO(255, 245, 244, 1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black12),
          ),
          child: Stack(
            children: [
              if(onDel!=null)
                IconButton(onPressed:(){
                  onDel!(b.title);
                }, icon: Icon(Icons.delete)),
              inside(b, context)
            ],
          ),
        ),
      ),
    );

  }
}
