import 'package:flutter/material.dart';

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
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onPressed: () {},
        ),
        Text(
          "NOW PLAYING",
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 1.2,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }
}

// 2. Album Art Widget
class AlbumArt extends StatelessWidget {
  const AlbumArt({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: kPrimaryColor,
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1614850523060-8da1d56ae167?q=80&w=2070&auto=format&fit=crop'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
    );
  }
}

// 3. Song Info Widget
class SongInfoSection extends StatefulWidget {
  final String title;
  final String artist;

  const SongInfoSection({super.key, required this.title, required this.artist});

  @override
  State<SongInfoSection> createState() => _SongInfoSectionState();
}

class _SongInfoSectionState extends State<SongInfoSection> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.artist,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
        Container(
          decoration: const BoxDecoration(
            color: kSecondaryColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? kPrimaryColor : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
          ),
        )
      ],
    );
  }
}

// 4. Progress Bar Widget
// อันนี้ต้องแก้เยอะมาก เลื่อนได้แล้วแต่ต้องทำให้ถูกและตรงกว่านี้
class ProgressBarSection extends StatefulWidget {
  const ProgressBarSection({super.key});

  @override
  State<ProgressBarSection> createState() => _ProgressBarSectionState();
}

class _ProgressBarSectionState extends State<ProgressBarSection> {
  double sliderValue = 0.3;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: kPrimaryColor,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
            thumbColor: Colors.white,
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
          ),
          child: Slider(
            value: sliderValue,
            onChanged: (value) {
              setState(() {
                sliderValue = value;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${(sliderValue * 4).toInt()}:${((sliderValue * 100) % 60).toInt().toString().padLeft(2, '0')}", 
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)
              ),
              Text("4:00", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

// 5. Playback Controls Widget
class PlaybackControls extends StatefulWidget {
  const PlaybackControls({super.key});

  @override
  State<PlaybackControls> createState() => _PlaybackControlsState();
}

class _PlaybackControlsState extends State<PlaybackControls> {
  bool isPlaying = false;

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
          onPressed: () {},
        ),
        // ปุ่ม Play
        GestureDetector(
          onTap: () {
            setState(() {
              isPlaying = !isPlaying;
            });
          },
          child: Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
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
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.repeat, color: kInactiveColor),
          onPressed: () {},
        ),
      ],
    );
  }
}

// 6. Volume Control Widget
class VolumeControl extends StatefulWidget {
  const VolumeControl({super.key});

  @override
  State<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  double volumeValue = 0.7;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.volume_down, color: Colors.white.withOpacity(0.5), size: 20),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.grey,
              inactiveTrackColor: Colors.grey.withOpacity(0.2),
              thumbColor: Colors.transparent, // ซ่อน Thumb
              trackHeight: 3.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0.0),
            ),
            child: Slider(
              value: volumeValue,
              onChanged: (value) {
                setState(() {
                  volumeValue = value;
                });
              },
            ),
          ),
        ),
        Icon(Icons.volume_up, color: Colors.white.withOpacity(0.5), size: 20),
      ],
    );
  }
}

// 7. Bottom Navigation
class BottomPlayerNav extends StatelessWidget {
  const BottomPlayerNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.playlist_play, color: Colors.white.withOpacity(0.6)),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.keyboard_arrow_up, color: Colors.white.withOpacity(0.6)),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.queue_music, color: Colors.white.withOpacity(0.6)),
          onPressed: () {},
        ),
      ],
    );
  }
}