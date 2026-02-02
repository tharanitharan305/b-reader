import 'dart:developer';

import 'package:btab/home/bloc/home_bloc.dart';
import 'package:btab/home/widgets/bookCard.dart';
import 'package:btab/home/widgets/searchBook.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../book_ui.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is BookLoaded) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookEditorScreen(pageModel: state.pageModel),
                ),
              );
            }
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            // Removed buildWhen to allow the UI to react to BookLoaded and restore the list
            builder: (context, state) {
              log("in home ui the state is $state");
              
              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is HomeError) {
                return Center(child: Text(state.message));
              }

              if (state is HomeLoaded || state is BookLoaded) {
                final books = (state is HomeLoaded) ? state.books : (state as BookLoaded).books;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Searchbook(onSearch: (String query) {
                      context.read<HomeBloc>().add(SearchBooksEvent(query));
                    }),
                    const SizedBox(height: 10),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: books.length,
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 320,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 288 / 462,
                        ),
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return Center(
                            child: Bookcard(
                              b: book,
                              onNav: (name) {
                                context.read<HomeBloc>().add(GetBookEvent(name));
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }

              return const Center(child: Text("Something went wrong"));
            },
          ),
        ),
      ),
    );
  }
}
