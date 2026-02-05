import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models.dart';
import '../../download_engine/data/download_service.dart';
import '../data/book.dart';
import '../data/home_repo.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepo homeRepo;
  final DownloadService downloadService;
  List<Book> _allBooks = [];
  String _currentFilter = 'all';
  String _currentSearchQuery = '';

  HomeBloc({required this.homeRepo, required this.downloadService}) : super(HomeInitial()) {
    on<HomeGetBooksEvent>(_onGetBooks);
    on<GetBookEvent>(_onGetBook);
    on<SearchBooksEvent>(_onSearchBooks);
    on<FilterBooksEvent>(_onFilterBooks);
  }

  Future<void> _onGetBooks(HomeGetBooksEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final offlineBooks = await downloadService.getAllOfflineBooks();
      _allBooks=offlineBooks;
      final serverBooks = await homeRepo.getBooks();


      // Merge logic
      Map<String, Book> mergedMap = {};
      
      for (var b in serverBooks) {
        b.isFromServer = true;
        mergedMap[b.title] = b;
      }

      for (var b in offlineBooks) {
        if (mergedMap.containsKey(b.title)) {
          mergedMap[b.title]!.isDownloaded = true;
        } else {
          b.isDownloaded = true;
          b.isFromServer = false;
          mergedMap[b.title] = b;
        }
      }

      _allBooks = mergedMap.values.toList();
      _applyFiltersAndEmit(emit);
    } catch (e) {

      emit(HomeError(e.toString(),_allBooks));
    }
  }

  Future<void> _onGetBook(GetBookEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      BbookModel? pageModel;
      // Check offline first
      pageModel = await downloadService.getOfflineBook(event.name);
      
      if (pageModel == null) {
        // Fetch from server if not found offline
        pageModel = await homeRepo.getBook(event.name);
      }
      
      emit(BookLoaded(pageModel!, _allBooks));
    } catch (e) {
      emit(HomeError(e.toString(),_allBooks));
    }
  }

  void _onSearchBooks(SearchBooksEvent event, Emitter<HomeState> emit) {
    _currentSearchQuery = event.query;
    _applyFiltersAndEmit(emit);
  }

  void _onFilterBooks(FilterBooksEvent event, Emitter<HomeState> emit) {
    _currentFilter = event.filter;
    _applyFiltersAndEmit(emit);
  }

  void _applyFiltersAndEmit(Emitter<HomeState> emit) {
    List<Book> filtered = _allBooks;

    // Apply Search
    if (_currentSearchQuery.isNotEmpty) {
      filtered = filtered
          .where((book) => book.title.toLowerCase().contains(_currentSearchQuery.toLowerCase()))
          .toList();
    }

    // Apply Filter
    if (_currentFilter == 'downloaded') {
      filtered = filtered.where((book) => book.isDownloaded).toList();
    }

    emit(HomeLoaded(filtered));
  }
}
