part of 'home_bloc.dart';

sealed class HomeEvent {}

class HomeGetBooksEvent extends HomeEvent {}

class GetBookEvent extends HomeEvent {
  final String name;
  GetBookEvent(this.name);
}

class SearchBooksEvent extends HomeEvent {
  final String query;
  SearchBooksEvent(this.query);
}

class FilterBooksEvent extends HomeEvent {
  final String filter; // 'all', 'downloaded'
  FilterBooksEvent(this.filter);
}
