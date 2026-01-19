import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:audio_service/audio_service.dart';

import '../services/audio_handler.dart'; 

const Color kPrimaryColor = Color(0xFF8B2CF5);
const Color kSecondaryColor = Color(0xFF2C2C35);
const Color kInactiveColor = Colors.grey;


// 1. Top Navigation Bar
class TopNavBar extends StatelessWidget {
  const TopNavBar({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white), onPressed: () {}),
        Text("NOW PLAYING", style: TextStyle(color: Colors.white.withOpacity(0.6), letterSpacing: 1.2, fontSize: 12, fontWeight: FontWeight.bold)),
        IconButton(icon: const Icon(Icons.more_horiz, color: Colors.white), onPressed: () {}),
      ],
    );
  }
}

// 2. Album Art Widget
class AlbumArt extends StatelessWidget {
  final String? artUri;
  const AlbumArt({super.key, this.artUri});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: kPrimaryColor,
        image: DecorationImage(image: NetworkImage(artUri ?? 'https://images.unsplash.com/photo-1614850523060-8da1d56ae167?q=80&w=2070'), fit: BoxFit.cover),
        boxShadow: [BoxShadow(color: kPrimaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
    );
  }
}

// 3. Song Info Widget
class SongInfoSection extends StatelessWidget {
  final String title;
  final String artist;
  const SongInfoSection({super.key, required this.title, required this.artist});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Text(artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.6))),
        ])),
        Container(decoration: const BoxDecoration(color: kSecondaryColor, shape: BoxShape.circle), child: IconButton(icon: const Icon(Icons.favorite_border, color: Colors.grey), onPressed: () {})),
      ],
    );
  }
}

// 4. Progress Bar Widget
class ProgressBarSection extends StatelessWidget {
  final Duration currentPosition;
  final Duration totalDuration;
  final Function(Duration) onSeek;
  const ProgressBarSection({super.key, required this.currentPosition, required this.totalDuration, required this.onSeek});

  @override
  Widget build(BuildContext context) {
    final double totalMilliseconds = totalDuration.inMilliseconds.toDouble();
    final double currentMilliseconds = currentPosition.inMilliseconds.toDouble();
    double sliderValue = (totalMilliseconds > 0) ? currentMilliseconds / totalMilliseconds : 0.0;
    sliderValue = sliderValue.clamp(0.0, 1.0);

    return Column(children: [
      SliderTheme(
        data: SliderTheme.of(context).copyWith(activeTrackColor: kPrimaryColor, inactiveTrackColor: Colors.grey.withOpacity(0.3), thumbColor: Colors.white, trackHeight: 4.0, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0), overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0)),
        child: Slider(value: sliderValue, min: 0.0, max: 1.0, onChanged: (value) { final newPositionMilliseconds = value * totalMilliseconds; onSeek(Duration(milliseconds: newPositionMilliseconds.toInt())); }),
      ),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 10.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(_formatDuration(currentPosition), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
        Text(_formatDuration(totalDuration), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
      ])),
    ]);
  }
  String _formatDuration(Duration duration) { String twoDigits(int n) => n.toString().padLeft(2, '0'); final minutes = twoDigits(duration.inMinutes.remainder(60)); final seconds = twoDigits(duration.inSeconds.remainder(60)); return "$minutes:$seconds"; }
}


class PlaybackControls extends StatelessWidget {
  final bool isPlaying;
  final bool isRepeat;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onRepeat;

  const PlaybackControls({
    super.key,
    required this.isPlaying,
    required this.isRepeat,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onRepeat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.shuffle, color: kInactiveColor),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
          onPressed: onPrevious,
        ),
        GestureDetector(
          onTap: onPlayPause,
          child: Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: kPrimaryColor.withOpacity(0.5), blurRadius: 20, spreadRadius: 2)
              ],
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
          onPressed: onNext,
        ),

        IconButton(
          icon: Icon(
            isRepeat ? Icons.repeat_one : Icons.repeat, 
            color: isRepeat ? kPrimaryColor : kInactiveColor
          ),
          onPressed: onRepeat,
        ),
      ],
    );
  }
}

// 6. Volume Control
class VolumeControl extends StatefulWidget {
  const VolumeControl({super.key});
  @override
  State<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  final _audioHandler = GetIt.I<AudioHandler>();
  double volumeValue = 1.0; 

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      IconButton(icon: Icon(Icons.volume_down, color: Colors.white.withOpacity(0.5), size: 20), onPressed: () { final newVal = (volumeValue - 0.1).clamp(0.0, 1.0); _updateVolume(newVal); }),
      Expanded(child: SliderTheme(data: SliderTheme.of(context).copyWith(activeTrackColor: Colors.grey, inactiveTrackColor: Colors.grey.withOpacity(0.2), thumbColor: Colors.white, trackHeight: 3.0, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0)), child: Slider(value: volumeValue, min: 0.0, max: 1.0, onChanged: (value) { _updateVolume(value); }))),
      IconButton(icon: Icon(Icons.volume_up, color: Colors.white.withOpacity(0.5), size: 20), onPressed: () { final newVal = (volumeValue + 0.1).clamp(0.0, 1.0); _updateVolume(newVal); }),
    ]);
  }
  void _updateVolume(double value) { setState(() { volumeValue = value; }); if (_audioHandler is MyAudioHandler) { (_audioHandler as MyAudioHandler).setVolume(value); } }
}

// 7. Bottom Navigation
class BottomPlayerNav extends StatelessWidget {
  const BottomPlayerNav({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(icon: Icon(Icons.playlist_play, color: Colors.white.withOpacity(0.6)), onPressed: () {}),
      IconButton(icon: Icon(Icons.keyboard_arrow_up, color: Colors.white.withOpacity(0.6)), onPressed: () {}),
      IconButton(icon: Icon(Icons.queue_music, color: Colors.white.withOpacity(0.6)), onPressed: () {}),
    ]);
  }
}
