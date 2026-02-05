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
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _player.setUrl(widget.url);
  }

  @override
  void dispose() {
    _removeOverlay();
    _player.dispose();
    super.dispose();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) =>
          Positioned(bottom: 30, left: 20, right: 20, child: _audioBar()),
    );

    //Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _audioBar() {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(12),
      color: Colors.black87,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Progress bar
            StreamBuilder<Duration>(
              stream: _player.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final total = _player.duration ?? Duration.zero;

                return Column(
                  children: [
                    Slider(
                      value: position.inMilliseconds.toDouble(),
                      max: total.inMilliseconds.toDouble().clamp(
                        1,
                        double.infinity,
                      ),
                      onChanged: (value) {
                        _player.seek(Duration(milliseconds: value.toInt()));
                      },
                      activeColor: Colors.pinkAccent,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [_timeText(position), _timeText(total)],
                    ),
                  ],
                );
              },
            ),

            /// Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder<PlayerState>(
                  stream: _player.playerStateStream,
                  builder: (context, snapshot) {
                    final playing = snapshot.data?.playing ?? false;

                    return IconButton(
                      iconSize: 32,
                      icon: Icon(
                        playing ? Icons.pause_circle : Icons.play_circle,
                        color: Colors.pinkAccent,
                      ),
                      onPressed: () {
                        playing ? _player.pause() : _player.play();
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    _player.pause();
                    _removeOverlay();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeText(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final m = twoDigits(d.inMinutes.remainder(60));
    final s = twoDigits(d.inSeconds.remainder(60));
    return Text(
      "$m:$s",
      style: const TextStyle(color: Colors.white, fontSize: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 28,
      icon: const Icon(Icons.volume_up_rounded, color: Colors.pinkAccent),
      onPressed: () async {
        await _player.play();
        _showOverlay();
      },
    );
  }
}
