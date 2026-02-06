import 'dart:convert';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoElement extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;

  const VideoElement({
    super.key,
    required this.url,
    this.width,
    this.height,
  });

  @override
  State<VideoElement> createState() => _VideoElementState();
}

class _VideoElementState extends State<VideoElement> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _initialized = false;

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
      headers: {
        "User-Agent": "Mozilla/5.0",
        "Accept": "*/*",
      },
    ),
  );

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  // 🔥 Hash URL → stable cache filename
  String _hashUrl(String url) {
    return sha1.convert(utf8.encode(url)).toString();
  }

  // 🔥 Download video safely
  Future<File> _downloadVideo(String rawUrl) async {
    final encodedUrl = Uri.encodeFull(rawUrl);

    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory("${dir.path}/video_cache");

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    final extension =
        Uri.parse(encodedUrl).path.split('.').last;

    final filePath =
        "${cacheDir.path}/${_hashUrl(encodedUrl)}.$extension";

    final file = File(filePath);

    if (await file.exists()) {
      print("Using cached video: $filePath");
      return file;
    }

    print("Downloading video...");
    print("FROM: $encodedUrl");

    await _dio.download(
      encodedUrl,
      filePath,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          final percent =
          (received / total * 100).toStringAsFixed(0);
          print("Download progress: $percent%");
        }
      },
    );

    print("Download finished!");
    return file;
  }

  Future<void> _initializePlayer() async {
    try {
      File videoFile;

      if (File(widget.url).existsSync()) {
        videoFile = File(widget.url);
      } else {
        videoFile = await _downloadVideo(widget.url);
      }

      _videoPlayerController =
          VideoPlayerController.file(videoFile);

      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        showControls: true,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
      );

      if (mounted) {
        setState(() => _initialized = true);
      }
    } catch (e, stack) {
      print("VIDEO ERROR: $e");
      print(stack);
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || _chewieController == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height ?? 200,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AspectRatio(
        aspectRatio:
        _videoPlayerController.value.aspectRatio,
        child: Chewie(controller: _chewieController!),
      ),
    );
  }
}
