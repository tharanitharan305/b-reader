import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../models.dart';
import '../../home/data/book.dart';

class DownloadService {
  final Dio _dio = Dio();
  final Uuid _uuid = const Uuid();

  static const String baseUrl = "http://192.168.0.8:3000/download_file";//'https://apidev.cloud/engin/download_file';

  /// Main function to save a book offline
  Future<void> saveBookOffline(BbookModel pageModel) async {
    log("saveBookOffline(service): starting for ${pageModel.bookName}");
    // 1. Convert Model to Mutable Map
    Map<String, dynamic> jsonMap = pageModel.toJson();
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String assetDir = '${appDir.path}/book_assets';
    await Directory(assetDir).create(recursive: true);

    log("saveBookOffline(service): asset directory created at $assetDir");
    log("saveBookOffline(service): starting asset traversal and download");
    await _traverseAndDownload(jsonMap, assetDir);
    log("saveBookOffline(service): download complete. saving to Hive...");

    var box = await Hive.openBox('offline_books');
    await box.put(pageModel.bookName, jsonMap);
    log("saveBookOffline(service): saved to 'offline_books' box");
    
    // Also save a summary for the home screen
    var summaryBox = await Hive.openBox('offline_summaries');
    await summaryBox.put(pageModel.bookName, {
      'title': pageModel.bookName,
      'version': pageModel.version,
      'image': jsonMap['image'] ?? "", 
    });
    log("saveBookOffline(service): saved to 'offline_summaries' box. Done.");
  }

  Future<void> _traverseAndDownload(dynamic node, String saveDir) async {
    if (node is Map<String, dynamic>) {
      if (node.containsKey('src') && node['src'] != null) {
        String url = node['src'];
        if (url.startsWith('http')) {
          log("traverseAndDownload(service): found remote asset: $url");
          String? localPath = await _downloadAsset(url, saveDir);
          if (localPath != null) {
            node['src'] = localPath;
            log("traverseAndDownload(service): updated map with local path: $localPath");
          }
        }
      }
      for (var value in node.values) {
        await _traverseAndDownload(value, saveDir);
      }
    } else if (node is List) {
      for (var item in node) {
        await _traverseAndDownload(item, saveDir);
      }
    }
  }

  Future<String?> _downloadAsset(String originalUrl, String saveDir) async {
    try {
      String extension = _getExtensionFromUrl(originalUrl);
      String fileName = '${_uuid.v4()}$extension';
      String savePath = '$saveDir/$fileName';

      if (File(savePath).existsSync()) {
        log("downloadAsset(service): file already exists: $savePath");
        return savePath;
      }

      log("downloadAsset(service): downloading from $baseUrl with data: {'url': $originalUrl}");
      await _dio.download(
        baseUrl,
        savePath,
        data: {'url': originalUrl},
        options: Options(method: 'POST'),
      );

      log("downloadAsset(service): download success: $savePath");
      return savePath;
    } catch (e) {
      log("downloadAsset(service): download failed for $originalUrl: ${e.toString()}");
      return null;
    }
  }

  String _getExtensionFromUrl(String url) {
    try {
      String path = Uri.parse(url).path;
      if (path.contains('.')) {
        return '.${path.split('.').last}';
      }
    } catch (_) {}
    return '.dat';
  }

  /// Helper to retrieve the book
  Future<BbookModel?> getOfflineBook(String bookName) async {
    log("getOfflineBook(service): opening box for $bookName");
    var box = await Hive.openBox('offline_books');
    var jsonMap = box.get(bookName);
    
    if (jsonMap != null) {
      log("getOfflineBook(service): book found in storage");
      return BbookModel.fromJson(Map<String, dynamic>.from(jsonMap));
    }
    log("getOfflineBook(service): book NOT found in storage");
    return null;
  }

  Future<List<Book>> getAllOfflineBooks() async {
    log("getAllOfflineBooks(service): fetching offline summaries");
    var summaryBox = await Hive.openBox('offline_summaries');
    List<Book> books = [];
    for (var key in summaryBox.keys) {
      var data = summaryBox.get(key);
      books.add(Book(
        id: key.toString(),
        title: data['title'],
        version: data['version'],
        image_url: data['image'],
        isDownloaded: true,
        isFromServer: false,
      ));
    }
    log("getAllOfflineBooks(service): found ${books.length} offline books");
    return books;
  }

  Future<bool> deleteBook(String bookName) async {
    log("deleteBook(service): starting deletion for '$bookName'");
    try {
      var box = await Hive.openBox('offline_books');
      log("deleteBook(service): 'offline_books' box opened");
      
      var summaryBox = await Hive.openBox('offline_summaries');
      log("deleteBook(service): 'offline_summaries' box opened");

      await box.delete(bookName);
      log("deleteBook(service): deleted '$bookName' from offline_books");
      
      await summaryBox.delete(bookName);
      log("deleteBook(service): deleted '$bookName' from offline_summaries");

      bool exists = box.containsKey(bookName);
      log("deleteBook(service): verification - book exists in offline_books? $exists");
      
      return !exists;
    } catch (e) {
      log("deleteBook(service): error during deletion: ${e.toString()}");
      return false;
    }
  }
}
