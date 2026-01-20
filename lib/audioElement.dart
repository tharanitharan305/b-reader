import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioElement extends StatefulWidget {
  final String url;

  const AudioElement({super.key, required this.url});

  @override
  State<AudioElement> createState() => _AudioElementState();
}

class _AudioElementState extends State<AudioElement> {
  final AudioPlayer _player = AudioPlayer();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _player.setUrl(widget.url).then((_) {
      setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const CircularProgressIndicator();
    }

    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final playing = snapshot.data?.playing ?? false;

        return IconButton(
          iconSize: 40,
          icon: Icon(
            playing ? Icons.pause_circle : Icons.play_circle,
          ),
          onPressed: () {
            playing ? _player.pause() : _player.play();
          },
        );
      },
    );
  }
}
