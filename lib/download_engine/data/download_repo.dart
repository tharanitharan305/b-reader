import 'dart:developer';
import 'download_service.dart';
import '../../models.dart';

class DownloadRepo {
  final DownloadService _downloadService;

  DownloadRepo(this._downloadService);

  /// Downloads and saves a book for offline use
  Future<void> downloadBook(BbookModel pageModel) async {
    log("downloadBook(repo): starting for ${pageModel.bookName}");
    try {
      await _downloadService.saveBookOffline(pageModel);
      log("downloadBook(repo): successfully saved ${pageModel.bookName}");
    } catch (e) {
      log("downloadBook(repo): error for ${pageModel.bookName}: ${e.toString()}");
      rethrow;
    }
  }

  /// Retrieves a book from offline storage
  Future<BbookModel?> getOfflineBook(String bookName) async {
    log("getOfflineBook(repo): fetching '$bookName'");
    try {
      final book = await _downloadService.getOfflineBook(bookName);
      log("getOfflineBook(repo): result for '$bookName' is ${book != null ? 'Found' : 'Not Found'}");
      return book;
    } catch (e) {
      log("getOfflineBook(repo): error fetching '$bookName': ${e.toString()}");
      rethrow;
    }
  }

  /// Optional: Check if a book is already downloaded
  Future<bool> isBookDownloaded(String bookName) async {
    log("isBookDownloaded(repo): checking '$bookName'");
    final book = await _downloadService.getOfflineBook(bookName);
    log("isBookDownloaded(repo): '$bookName' is ${book != null ? 'Downloaded' : 'Not Downloaded'}");
    return book != null;
  }

  Future<bool> deleteBook(String bookName) async {
    log("deleteBook(repo): requesting deletion for '$bookName'");
    try {
      final success = await _downloadService.deleteBook(bookName);
      log("deleteBook(repo): deletion for '$bookName' was ${success ? 'Successful' : 'Failed'}");
      return success;
    } catch (e) {
      log("deleteBook(repo): exception during deletion of '$bookName': ${e.toString()}");
      rethrow;
    }
  }
}
