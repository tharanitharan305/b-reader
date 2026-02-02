import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models.dart';
import '../data/book.dart';
import '../data/home_repo.dart';
import '../data/home_services.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepo homeRepo;
  List<Book> _allBooks = [];

  HomeBloc({required this.homeRepo}) : super(HomeInitial()){
    on<HomeGetBooksEvent>(_onGetBooks);
    on<GetBookEvent>(_onGetBook);
    on<SearchBooksEvent>(_onSearchBooks);
  }

  Future<void> _onGetBooks(HomeGetBooksEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      _allBooks = await homeRepo.getBooks();
      emit(HomeLoaded(_allBooks));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onGetBook(GetBookEvent event, Emitter<HomeState> emit) async {
    log("getBook(bloc):entered bloc");
    emit(HomeLoading());
    try {
      log("getBook(bloc):request sent to repo with name ${event.name}");
      final pageModel = await homeRepo.getBook(event.name);
      log("getBook(bloc):response got successfully from repo");
      emit(BookLoaded(pageModel,_allBooks));
      log("getBook(bloc):emitting data to ui");
    } catch (e) {
      log("getBook(bloc):emitting error ${e.toString()} from bloc");
      emit(HomeError(e.toString()));
    }
  }

  void _onSearchBooks(SearchBooksEvent event, Emitter<HomeState> emit) {
    if (event.query.isEmpty) {
      emit(HomeLoaded(_allBooks));
    } else {
      final filteredBooks = _allBooks
          .where((book) => book.title.toLowerCase().contains(event.query.toLowerCase()))
          .toList();
      emit(HomeLoaded(filteredBooks));
    }
  }
}
