import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; 
import 'package:flutter/gestures.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 🌟 เพิ่ม import นี้

import '../models/song_model.dart'; 
import '../widgets/app_widgets.dart';

import 'package:get_it/get_it.dart';
import 'package:audio_service/audio_service.dart';
import '../services/audio_handler.dart';
import 'player_screen.dart';
import '../services/user_hive_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Box? userBox; 
  String displayUsername = "Guest"; // 🌟 เพิ่มตัวแปรเก็บชื่อ

  @override
  void initState() {
    super.initState();
    _initBox();
  }

  Future<void> _initBox() async {
    const storage = FlutterSecureStorage();
    // 🌟 ดึง username จาก Storage
    final name = await storage.read(key: 'username');
    final box = await UserHiveManager.getUserBox();
    
    if (mounted) {
      setState(() {
        userBox = box;
        displayUsername = name ?? "Guest"; // ถ้าหาไม่เจอให้เป็น Guest
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userBox == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF151521),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF8B2CF5))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF151521),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // 🌟 ส่ง displayUsername เข้าไปใน Header
                _HomeHeader(username: displayUsername),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SectionTitle(title: "For You"),
                    Icon(Icons.history, color: Colors.white.withOpacity(0.5)),
                  ],
                ),
                const SizedBox(height: 20),
                _MadeForYouGrid(userBox: userBox!),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(),
          CustomBottomNavBar(selectedIndex: 0),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final String username;
  const _HomeHeader({required this.username});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          // คุณสามารถเปลี่ยนเป็นรูปโปรไฟล์จริงได้ถ้ามี artUrl ใน UserData
          backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=$username&background=8B2CF5&color=fff'),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Good Morning", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
            // 🌟 แสดงชื่อผู้ใช้จริง
            Text(
              username, 
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
            ),
          ],
        ),
      ],
    );
  }
}

// For You
class _MadeForYouGrid extends StatelessWidget {
  final Box userBox; 
  const _MadeForYouGrid({required this.userBox});

  @override
  Widget build(BuildContext context) {
    final audioHandler = GetIt.I<AudioHandler>();

    return ValueListenableBuilder(
      valueListenable: userBox.listenable(keys: ['home_songs']),
      builder: (context, Box box, _) {
        final Map<dynamic, dynamic> rawSongsMap = box.get('home_songs', defaultValue: <dynamic, dynamic>{});
        final List<SongModel> songs = rawSongsMap.values.cast<SongModel>().toList();

        if (songs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 50),
              child: Text("No songs available", style: TextStyle(color: Colors.grey)),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 20,
            childAspectRatio: 0.65,
          ),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            return _buildItem(
              context,
              audioHandler,
              title: song.title,
              subtitle: song.artist,
              artUrl: song.artUrl,
              mp3Url: song.audioUrl,
            );
          },
        );
      },
    );
  }

  Widget _buildItem(
    BuildContext context,
    AudioHandler audioHandler, {
    required String title,
    required String subtitle,
    required String artUrl,
    required String mp3Url,
  }) {
    return GestureDetector(
      onTap: () async {
        if (audioHandler is MyAudioHandler) {
          await audioHandler.loadSong(mp3Url, title, subtitle, artUrl);
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PlayerScreen()),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(image: NetworkImage(artUrl), fit: BoxFit.cover),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B2CF5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // ชื่อเพลง
          Text(
            title, 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 1, 
            overflow: TextOverflow.ellipsis,
          ),
          // ชื่อศิลปิน
          Text(
            subtitle, 
            style: const TextStyle(color: Colors.grey, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
