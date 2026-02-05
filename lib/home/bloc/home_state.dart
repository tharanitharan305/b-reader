part of 'home_bloc.dart';

sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final List<Book> books;
  HomeLoaded(this.books);
}

final class HomeError extends HomeState {
  final String message;
  final List<Book> books;
  HomeError(this.message,this.books);
}
final class BookLoaded extends HomeState {
  final BbookModel pageModel;
  final List<Book> books;
  BookLoaded(this.pageModel,this.books);
}