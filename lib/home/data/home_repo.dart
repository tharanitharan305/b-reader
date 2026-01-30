import 'dart:developer';

import '../../models.dart';
import 'book.dart';
import 'home_services.dart';

class HomeRepo {
  final HomeServices _homeServices;

  HomeRepo(this._homeServices);

  Future<List<Book>> getBooks() async {
    try {
      print("in repo1");
      final books=await _homeServices.getBooks();
      print("in repo2");
      print(books);
      return books;
    } catch (e) {
      rethrow;
    }
  }
  Future<PageModel> getBook(String title) async{
    try{
      log("getBook:entered repo with title $title");
      final pageModel=await _homeServices.getBook(title);
      log("getBook:repo got data with out error");
      return pageModel;
    }catch(e){
      log("getBook:repo got error ${e.toString()}");
      rethrow;

    }

  }
}
