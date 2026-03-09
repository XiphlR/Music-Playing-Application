import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import '../widgets/app_widgets.dart';
import '../services/audio_handler.dart';
import '../services/user_hive_manager.dart';
import '../models/song_model.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  bool isQueueSelected = true;
  final _audioHandler = GetIt.I<AudioHandler>();

  // ฟังก์ชันช่วยจัดฟอร์แมตเวลา 00:00
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151521),
      bottomNavigationBar: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(),
          CustomBottomNavBar(selectedIndex: 2),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const _LibraryHeader(),
              const SizedBox(height: 20),
              _buildToggleSwitch(),
              const SizedBox(height: 30),
              
              // สลับเนื้อหาตามปุ่มที่เลือก
              isQueueSelected ? _buildQueueContent() : _buildPlaylistsContent(),
              const SizedBox(height: 100), // เว้นที่กัน MiniPlayer ทับ
            ],
          ),
        ),
      ),
    );
  }

  // --- ส่วน Queue (ข้อมูลจาก AudioHandler) ---
  Widget _buildQueueContent() {
    return StreamBuilder<MediaItem?>(
      stream: _audioHandler.mediaItem,
      builder: (context, snapshot) {
        final currentSong = snapshot.data;
        // ดึงรายการคิวปัจจุบัน
        final queue = (_audioHandler as MyAudioHandler).currentQueue;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("NOW PLAYING", style: TextStyle(color: Color(0xFF8B2CF5), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 15),
            
            if (currentSong != null) ...[
              // แสดงเพลงที่กำลังเล่น (แสดงปุ่มสองขีดปกติ)
              _buildSongTile(
                currentSong.title, 
                currentSong.artist ?? "Unknown", 
                currentSong.artUri.toString(), 
                isPlaying: true
              ),
              
              // 🌟 แถบ Progress Bar สำหรับกรอเพลง
              StreamBuilder<Duration>(
                stream: AudioService.position,
                builder: (context, posSnapshot) {
                  final position = posSnapshot.data ?? Duration.zero;
                  final duration = currentSong.duration ?? Duration.zero;

                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          activeTrackColor: const Color(0xFF8B2CF5),
                          inactiveTrackColor: Colors.white10,
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: position.inMilliseconds.toDouble().clamp(0, duration.inMilliseconds.toDouble() + 1),
                          min: 0,
                          max: duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1.0,
                          onChanged: (val) {
                            _audioHandler.seek(Duration(milliseconds: val.toInt()));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(position), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                            Text(_formatDuration(duration), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ] else
              const Center(child: Text("No song playing", style: TextStyle(color: Colors.grey))),
            
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Up Next", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () async {
                    await (_audioHandler).clearQueue();
                    setState(() {});
                                    },
                  child: const Text("Clear Queue", style: TextStyle(color: Color(0xFF8B2CF5), fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // 🌟 แสดงรายการคิวถัดไป พร้อมปุ่มลบแทนที่ปุ่มสองขีด
            ...queue.asMap().entries.where((entry) => entry.key > 0).map((entry) {
              final item = entry.value;
              return _buildSongTile(
                item.title, 
                item.artist ?? "Unknown", 
                item.artUri.toString(),
              );
            }),
          ],
        );
      },
    );
  }

  // --- ส่วน Playlists ---
  Widget _buildPlaylistsContent() {
    return FutureBuilder<List<SongModel>>(
      future: UserHiveManager.getFavorites(),
      builder: (context, snapshot) {
        final favSongs = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Your Playlists", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Icon(Icons.add, color: Color(0xFF8B2CF5)),
              ],
            ),
            const SizedBox(height: 20),
            _buildPlaylistItem("My Favorites", "${favSongs.length} songs", Icons.favorite, () async {
              if (favSongs.isNotEmpty) {
                if (_audioHandler is MyAudioHandler) {
                  await (_audioHandler).clearQueue();
                  for (var s in favSongs) {
                    await (_audioHandler).addSongToQueue(s);
                  }
                }
                _audioHandler.play();
              }
            }),
          ],
        );
      },
    );
  }

  // 🌟 ส่วน Song Tile: แก้ไข Trailing ให้ปุ่มลบมาแทนที่ปุ่มสองขีด
  Widget _buildSongTile(String title, String artist, String imgUrl, {bool isPlaying = false, VoidCallback? onDelete}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(imgUrl, width: 55, height: 55, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: Colors.grey, width: 55)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: TextStyle(color: isPlaying ? const Color(0xFF8B2CF5) : Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                Text(
                  artist, 
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // 🌟 เช็คเงื่อนไข: ถ้ามี onDelete (Up Next) ให้แสดงปุ่มลบ ถ้าไม่มี (Now Playing) ให้แสดงปุ่มสองขีด
          onDelete != null 
            ? IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 22),
                onPressed: onDelete,
              )
            : const Icon(Icons.drag_handle, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildPlaylistItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 55, height: 55,
        decoration: BoxDecoration(color: const Color(0xFF2C2C35), borderRadius: BorderRadius.circular(15)),
        child: Icon(icon, color: const Color(0xFF8B2CF5)),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: const Icon(Icons.play_circle_fill, color: Color(0xFF8B2CF5)),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      width: double.infinity, height: 50,
      decoration: BoxDecoration(color: const Color(0xFF2C2C35), borderRadius: BorderRadius.circular(25)),
      child: Row(
        children: [
          _toggleBtn("Queue", isQueueSelected, () => setState(() => isQueueSelected = true)),
          _toggleBtn("Playlists", !isQueueSelected, () => setState(() => isQueueSelected = false)),
        ],
      ),
    );
  }

  Widget _toggleBtn(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: active ? const Color(0xFF8B2CF5) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _LibraryHeader extends StatelessWidget {
  const _LibraryHeader();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        const Text("Library", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const Spacer(),
      ],
    );
  }
}
