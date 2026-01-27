import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/book.dart';
import '../data/home_repo.dart';
import '../data/home_services.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()){
    on<HomeGetBooksEvent>(getBooks);
  }
getBooks(HomeEvent event,Emitter<HomeState> emit)async{
  emit(HomeLoading());
  try{
    final books=await HomeRepo(HomeServices()).getBooks();
    print(books);
    emit(HomeLoaded(books));
  }catch(e){
    emit(HomeError(e.toString()));
  }
}

}