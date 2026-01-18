import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF8B2CF5);
const Color kSecondaryColor = Color(0xFF2C2C35);
const Color kInactiveColor = Colors.grey;

// 1. Top Navigation Bar (เหมือนเดิม)
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

// 2. Album Art Widget (แก้ให้รับ URL รูปภาพได้)
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
        image: DecorationImage(
          image: NetworkImage(artUri ?? 'https://images.unsplash.com/photo-1614850523060-8da1d56ae167?q=80&w=2070'),
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

// 3. Song Info Widget (Stateless, รับค่ามาแสดง)
class SongInfoSection extends StatelessWidget {
  final String title;
  final String artist;

  const SongInfoSection({super.key, required this.title, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: kSecondaryColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.grey),
            onPressed: () {
              // TODO: Implement favorites logic with Hive later
            },
          ),
        )
      ],
    );
  }
}

// 4. Progress Bar Widget (แก้ไขให้รับค่า Position และ Duration จาก AudioService)
class ProgressBarSection extends StatelessWidget {
  final Duration currentPosition;
  final Duration totalDuration;
  final Function(Duration) onSeek;

  const ProgressBarSection({
    super.key,
    required this.currentPosition,
    required this.totalDuration,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    // คำนวณ % ของ Slider (0.0 - 1.0)
    double sliderValue = 0.0;
    if (totalDuration.inMilliseconds > 0) {
      sliderValue = currentPosition.inMilliseconds / totalDuration.inMilliseconds;
      sliderValue = sliderValue.clamp(0.0, 1.0); // ป้องกันค่าเกิน
    }

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
              // แปลงค่า Slider (0.0-1.0) กลับเป็น Duration เพื่อ Seek
              final newPosition = Duration(
                milliseconds: (value * totalDuration.inMilliseconds).toInt(),
              );
              onSeek(newPosition);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(currentPosition),
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
              ),
              Text(
                _formatDuration(totalDuration),
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ฟังก์ชันแปลงเวลา 125 -> 02:05
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}

// 5. Playback Controls Widget (รับสถานะ Playing และ Callbacks)
class PlaybackControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const PlaybackControls({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
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
        // ปุ่ม Play/Pause
        GestureDetector(
          onTap: onPlayPause,
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
          onPressed: onNext,
        ),
        IconButton(
          icon: const Icon(Icons.repeat, color: kInactiveColor),
          onPressed: () {},
        ),
      ],
    );
  }
}

// 6. Volume Control (UI Only สำหรับตอนนี้)
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
              thumbColor: Colors.transparent,
              trackHeight: 3.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0.0),
            ),
            child: Slider(
              value: volumeValue,
              onChanged: (value) {
                setState(() {
                  volumeValue = value;
                  // TODO: ต่อกับ AudioService เพื่อปรับเสียงจริง (ถ้าต้องการ)
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

// 7. Bottom Navigation (เหมือนเดิม)
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
