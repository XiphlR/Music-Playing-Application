import 'package:flutter/material.dart';
import '../widgets/player_widgets.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            children: [
              // 1. Top Bar (ปุ่มลง, NOW PLAYING, เมนู)
              const TopNavBar(),
              
              const SizedBox(height: 30),
              
              // 2. Album Art (รูปปก)
              const AlbumArt(),
              
              const SizedBox(height: 30),
              
              // 3. Song Info (ชื่อเพลง, ศิลปิน, ปุ่มหัวใจ)
              const SongInfoSection(
                title: "The Future of UI",
                artist: "Design Matters Podcast",
              ),
              
              const SizedBox(height: 20),
              
              // 4. Progress Bar (แถบเวลา)
              const ProgressBarSection(),
              
              const SizedBox(height: 10),
              
              // 5. Playback Controls (ปุ่มเล่นเพลง)
              const PlaybackControls(),
              
              const SizedBox(height: 20),
              
              // 6. Volume Control (แถบเสียง)
              const VolumeControl(),
              
              const Spacer(),
              
              // 7. Bottom Navigation (แถบล่างสุด)
              const BottomPlayerNav(),
            ],
          ),
        ),
      ),
    );
  }
}