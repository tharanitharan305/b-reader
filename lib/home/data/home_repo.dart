import 'book.dart';
import 'home_services.dart';

class HomeRepo {
  final HomeServices _homeServices;

  HomeRepo(this._homeServices);

  Future<Book> getBooks() async {
    try {
      return await _homeServices.getBooks();
    } catch (e) {
      rethrow;
    }
  }
}
