import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/audio_handler.dart';

import '../widgets/app_widgets.dart'; 
import '../models/song_model.dart'; 
import 'auth_screen.dart';
import 'player_screen.dart';
import '../services/user_hive_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  String _username = "Guest";
  
  List<SongModel> _recentSongs = [];
  List<SongModel> _favoriteSongs = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    String? token = await _storage.read(key: 'token');
    String? storedName = await _storage.read(key: 'username');

    if (token == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
      await _fetchUserData(storedName ?? "User");
    }
  }

  Future<void> _fetchUserData(String username) async {
    try {
      List<SongModel> loadedFavorites = await UserHiveManager.getFavorites();
      List<SongModel> loadedRecents = await UserHiveManager.getRecentSongs();

      if (mounted) {
        setState(() {
          _username = username;
          _recentSongs = loadedRecents;
          _favoriteSongs = loadedFavorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _username = username;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      final audioHandler = GetIt.I<AudioHandler>();
      if (audioHandler is MyAudioHandler) {
        await audioHandler.clearUserSession();
      }
    } catch (e) {
      debugPrint("Error clearing audio session: $e");
    }

    await _storage.deleteAll();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _removeFavorite(SongModel song) async {
    await UserHiveManager.toggleFavorite(song, false);
    setState(() {
      _favoriteSongs.removeWhere((s) => s.id == song.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF151521),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF8B2CF5))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF151521),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 160),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const _ProfileAppBar(),
                  
                  const SizedBox(height: 20),
                  _UserInfoSection(username: _username),

                  const SizedBox(height: 30),
                  const SectionTitle(title: "Jump Back In"),

                  const SizedBox(height: 15),
                  _recentSongs.isEmpty 
                      ? Center(child: Text("No recently played songs.", style: TextStyle(color: Colors.white.withOpacity(0.5))))
                      : _JumpBackInList(songs: _recentSongs),

                  const SizedBox(height: 30),
                  const SectionTitle(title: "Your Favorites"),

                  const SizedBox(height: 10),
                  _favoriteSongs.isEmpty 
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text("No favorite songs yet.", style: TextStyle(color: Colors.white.withOpacity(0.5))),
                          )
                        )
                      : _FavoritesList(songs: _favoriteSongs, onRemoveFav: _removeFavorite),

                  const SizedBox(height: 30),
                  const SectionTitle(title: "Account"),

                  const SizedBox(height: 15),
                  _LogoutButton(onLogout: _logout),
                ],
              ),
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  MiniPlayer(),
                  CustomBottomNavBar(selectedIndex: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ส่วนของ Widgets ย่อยต่าง ๆ
// ==========================================

class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Profile", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),
            IconButton(icon: const Icon(Icons.settings, color: Colors.white), onPressed: () {}),
          ],
        )
      ],
    );
  }
}

class _UserInfoSection extends StatelessWidget {
  final String username;
  const _UserInfoSection({required this.username});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: const Color(0xFF8B2CF5).withOpacity(0.5), blurRadius: 30, spreadRadius: 1)],
          ),
          child: CircleAvatar(
            radius: 50,
            // เปลี่ยนรูป
            backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=$username&background=8B2CF5&color=fff&size=200'),
          ),
        ),
        const SizedBox(height: 15),
        Text(username, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
            children: [
              TextSpan(text: "@${username.toLowerCase().replaceAll(' ', '')} • "),
              const TextSpan(text: "Premium", style: TextStyle(color: Color(0xFF8B2CF5), fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B2CF5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("Edit Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(color: const Color(0xFF2C2C35), borderRadius: BorderRadius.circular(30)),
              child: IconButton(icon: const Icon(Icons.qr_code, color: Colors.white), onPressed: () {}),
            )
          ],
        )
      ],
    );
  }
}

class _JumpBackInList extends StatelessWidget {
  final List<SongModel> songs; 
  const _JumpBackInList({required this.songs});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: songs.map((song) => _buildCard(context, song)).toList(),
      ),
    );
  }

  Widget _buildCard(BuildContext context, SongModel song) {
    final audioHandler = GetIt.I<AudioHandler>();

    return GestureDetector(
      onTap: () async {
        // 🌟 กดแล้วเล่นเพลงทันที
        if (audioHandler is MyAudioHandler) {
          await audioHandler.loadSong(song.audioUrl, song.title, song.artist, song.artUrl);
          if (context.mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PlayerScreen()));
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        width: 110,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                height: 110,
                width: 110,
                color: const Color(0xFF2C2C35),
                child: Image.network(
                  song.artUrl, 
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.music_note, color: Colors.white70, size: 40));
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  final List<SongModel> songs; 
  final Function(SongModel) onRemoveFav;
  
  const _FavoritesList({required this.songs, required this.onRemoveFav});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: songs.map((song) => _buildListItem(context, song)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, SongModel song) {
    final audioHandler = GetIt.I<AudioHandler>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell( // ใช้ InkWell เพื่อให้กดได้สวยงาม
        onTap: () async {
          // 🌟 กดแล้วเล่นเพลงทันที
          if (audioHandler is MyAudioHandler) {
            await audioHandler.loadSong(song.audioUrl, song.title, song.artist, song.artUrl);
            if (context.mounted) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PlayerScreen()));
            }
          }
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 50,
                height: 50,
                color: const Color(0xFF2C2C35),
                child: Image.network(
                  song.artUrl, 
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.music_note, color: Colors.white70));
                  },
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(song.artist, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: Color(0xFF8B2CF5), size: 20), 
              onPressed: () => onRemoveFav(song),
            ),
            Icon(Icons.more_vert, color: Colors.white.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;
  const _LogoutButton({required this.onLogout});

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C35), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            "Log Out",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to log out?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), 
              child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); 
                try {
                  final audioHandler = GetIt.I<AudioHandler>();
                  await audioHandler.stop(); 
                } catch (e) {
                  debugPrint("Error stopping audio on logout: $e");
                }
                onLogout(); 
              },
              child: const Text("Log Out", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLogoutConfirmation(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C35).withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, color: Colors.redAccent),
              SizedBox(width: 10),
              Text("Log Out", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
