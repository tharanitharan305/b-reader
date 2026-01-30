import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';class VideoElement extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;

  const VideoElement({super.key, required this.url, this.width, this.height});

  @override
  State<VideoElement> createState() => _VideoElementState();
}

class _VideoElementState extends State<VideoElement> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return SizedBox(
        width: widget.width,
        height: widget.height ?? 200,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    Widget videoContent = Stack(
      alignment: Alignment.center,
      children: [
        VideoPlayer(_controller),
        if (!_controller.value.isPlaying)
          const Icon(
            Icons.play_circle_fill,
            size: 64,
            color: Colors.white,
          ),
      ],
    );

    // If explicit width/height are provided, use SizedBox. Otherwise, use AspectRatio.
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.value.isPlaying ? _controller.pause() : _controller.play();
        });
      },
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: widget.width != null && widget.height != null
            ? videoContent
            : AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: videoContent,
        ),
      ),
    );
  }
}