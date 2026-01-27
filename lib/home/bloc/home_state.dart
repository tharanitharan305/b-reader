part of 'home_bloc.dart';

sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final Book books;
  HomeLoaded(this.books);
}

final class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
