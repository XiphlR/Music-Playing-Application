import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:audio_service/audio_service.dart';

import '../widgets/app_widgets.dart';
import '../models/song_model.dart';
import '../services/audio_handler.dart';
import 'player_screen.dart';
import '../services/user_hive_manager.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151521),
      
      // เมนูและ MiniPlayer ติดล่างตลอดเวลา
      bottomNavigationBar: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(),
          CustomBottomNavBar(selectedIndex: 1),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const _SearchHeader(),
              const SizedBox(height: 15),
              
              _SearchBar(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              
              const SizedBox(height: 15),

              if (_searchQuery.isNotEmpty) 
                _SearchResultsList(searchQuery: _searchQuery)
              else ...[
                const SizedBox(height: 25),
                const _RecentSearchesList(), 
                const SizedBox(height: 100),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// --- ส่วนแสดงผลการค้นหา ---
class _SearchResultsList extends StatelessWidget {
  final String searchQuery;
  const _SearchResultsList({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Box>(
      future: UserHiveManager.getUserBox(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 50),
            child: Center(child: CircularProgressIndicator(color: Color(0xFF8B2CF5))),
          );
        }

        final userBox = snapshot.data;
        if (userBox == null) return const SizedBox();

        final Map<dynamic, dynamic> rawSongsMap = userBox.get('home_songs', defaultValue: <dynamic, dynamic>{});
        final List<SongModel> allSongs = rawSongsMap.values.cast<SongModel>().toList();
        
        final results = allSongs.where((song) {
          final title = (song.title).toLowerCase();
          final artist = (song.artist).toLowerCase();
          final query = searchQuery.toLowerCase();
          return title.contains(query) || artist.contains(query);
        }).toList();

        if (results.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Center(
              child: Text("No results found for '$searchQuery'", style: const TextStyle(color: Colors.grey)),
            ),
          );
        }

        final audioHandler = GetIt.I<AudioHandler>();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final song = results[index];

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  song.artUrl, 
                  width: 55, height: 55, fit: BoxFit.cover, 
                  errorBuilder: (_,__,___) => Container(width: 55, height: 55, color: Colors.grey.shade800, child: const Icon(Icons.music_note, color: Colors.white24))
                ),
              ),
              title: Text(song.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(song.artist, style: TextStyle(color: Colors.white.withOpacity(0.5))),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🌟 ปุ่ม Add to Queue
                  IconButton(
                    icon: const Icon(Icons.playlist_add, color: Color(0xFF8B2CF5)),
                    onPressed: () async {
                      if (audioHandler is MyAudioHandler) {
                        await audioHandler.addSongToQueue(song);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added "${song.title}" to queue'), duration: const Duration(seconds: 1)),
                          );
                        }
                      }
                    },
                  ),
                  const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                ],
              ),
              onTap: () async {
                // บันทึกประวัติ
                List<String> recents = await UserHiveManager.getRecentSearches();
                recents.remove(song.id);
                recents.insert(0, song.id);
                if (recents.length > 5) recents = recents.sublist(0, 5);
                await UserHiveManager.saveRecentSearches(recents);
                await UserHiveManager.addRecentSong(song);

                if (audioHandler is MyAudioHandler) {
                  await audioHandler.loadSong(song.audioUrl, song.title, song.artist, song.artUrl);
                }
                if (context.mounted) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PlayerScreen()));
                }
              },
            );
          },
        );
      }
    );
  }
}

// --- ประวัติการค้นหาล่าสุด ---
class _RecentSearchesList extends StatefulWidget {
  const _RecentSearchesList();
  @override
  State<_RecentSearchesList> createState() => _RecentSearchesListState();
}

class _RecentSearchesListState extends State<_RecentSearchesList> {
  List<SongModel> _recentSongs = [];

  @override
  void initState() {
    super.initState();
    _loadRecents(); 
  }

  Future<void> _loadRecents() async {
    final recentIds = await UserHiveManager.getRecentSearches();
    if (recentIds.isNotEmpty) {
      final userBox = await UserHiveManager.getUserBox();
      final Map<dynamic, dynamic> rawSongsMap = userBox.get('home_songs', defaultValue: <dynamic, dynamic>{});
      final List<SongModel> allSongs = rawSongsMap.values.cast<SongModel>().toList();
      
      setState(() {
        _recentSongs = recentIds.map((id) => allSongs.firstWhere((s) => s.id == id, orElse: () => SongModel(id: '', title: '', artist: '', artUrl: '', audioUrl: ''))).where((s) => s.id.isNotEmpty).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_recentSongs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             const Text("Recent searches", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
             GestureDetector(
               onTap: () async {
                 await UserHiveManager.clearRecentSearches();
                 setState(() => _recentSongs = []);
               },
               child: Text("CLEAR ALL", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold)),
             ),
          ],
        ),
        const SizedBox(height: 15),
        ..._recentSongs.map((song) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(song.artUrl, width: 50, height: 50, fit: BoxFit.cover),
          ),
          title: Text(song.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          subtitle: Text(song.artist, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          trailing: IconButton(
            icon: const Icon(Icons.close, color: Colors.white54, size: 20),
            onPressed: () async {
              List<String> recents = await UserHiveManager.getRecentSearches();
              recents.remove(song.id);
              await UserHiveManager.saveRecentSearches(recents);
              _loadRecents();
            },
          ),
          onTap: () {
            final audioHandler = GetIt.I<AudioHandler>();
            if (audioHandler is MyAudioHandler) {
              audioHandler.loadSong(song.audioUrl, song.title, song.artist, song.artUrl);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PlayerScreen()));
            }
          },
        )),
      ],
    );
  }
}

// --- UI Components อื่นๆ ---
class _SearchHeader extends StatelessWidget {
  const _SearchHeader();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Search", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        IconButton(icon: const Icon(Icons.camera_alt_outlined, color: Colors.white), onPressed: () {}),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 50,
      decoration: BoxDecoration(color: const Color(0xFF2C2C35), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(hintText: "Artists or songs", hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)), border: InputBorder.none),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(onTap: () { controller.clear(); onChanged(''); }, child: const Icon(Icons.close, color: Colors.white54)),
        ],
      ),
    );
  }
}
