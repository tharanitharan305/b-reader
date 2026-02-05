import 'dart:developer';

import 'package:btab/download_engine/bloc/download_bloc.dart';
import 'package:btab/home/bloc/home_bloc.dart';
import 'package:btab/home/widgets/bookCard.dart';
import 'package:btab/home/widgets/chip.dart';
import 'package:btab/home/widgets/searchBook.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../book_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(actions: [IconButton(onPressed: (){
          context.read<HomeBloc>().add(HomeGetBooksEvent());
        }, icon: Icon(Icons.refresh))],),
        body: BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is BookLoaded) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(value: context.read<DownloadBloc>(),child: BookEditorScreen(pageModel: state.pageModel),),
                ),
              );
            }
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              log("in home ui the state is $state");
              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is HomeLoaded || state is BookLoaded|| (state is HomeError && (state.message.contains("Connection failed")||state.message.contains("Connection refused")))) {
                final books = (state is HomeLoaded) ? state.books: (state is HomeError)?state.books: (state as BookLoaded).books;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Searchbook(onSearch: (String query) {
                      context.read<HomeBloc>().add(SearchBooksEvent(query));
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          FilterChipWidget(
                            label: "All",
                            isSelected: _selectedFilter == 'all',
                            onTap: () {
                              setState(() => _selectedFilter = 'all');
                              context.read<HomeBloc>().add(FilterBooksEvent('all'));
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChipWidget(
                            label: "Downloaded",
                            isSelected: _selectedFilter == 'downloaded',
                            onTap: () {
                              setState(() => _selectedFilter = 'downloaded');
                              context.read<HomeBloc>().add(FilterBooksEvent('downloaded'));
                            },
                          ),
                        ],
                      ),
                    ),
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
                          
                          // Determine color based on status
                          Color cardColor = const Color.fromRGBO(255, 245, 244, 1); // Default
                          if (book.isDownloaded && book.isFromServer) {
                            cardColor = Colors.yellow.shade50;
                          } else if (book.isDownloaded && !book.isFromServer) {
                            cardColor = Colors.green.shade50;
                          }

                          return Center(
                            child: Bookcard(
                              b: book,
                              cardColor: cardColor,
                              onNav: (name) {
                                context.read<HomeBloc>().add(GetBookEvent(name));
                              },
                              onDel: book.isDownloaded?(name) {
                                context.read<DownloadBloc>().add(DeleteBook(name));
                              }:null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              if (state is HomeError) {
                return Center(child: Text(state.message));
              }
              return const Center(child: Text("Something went wrong"));
            },
          ),
        ),
      ),
    );
  }
}
