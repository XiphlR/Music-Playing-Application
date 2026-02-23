import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; 
import '../models/song_model.dart'; 
import '../widgets/app_widgets.dart';
import 'package:flutter/gestures.dart';

import 'package:get_it/get_it.dart';
import 'package:audio_service/audio_service.dart';
import '../services/audio_handler.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isHiveReady = false; 

  @override
  void initState() {
    super.initState();
    _setupInitialSongs();
  }

  // ทดลองเพิ่มเพลงลง Hive
  Future<void> _setupInitialSongs() async {
    final box = await Hive.openBox<SongModel>('home_songs');
    
    // ลองเอาออกชั่วคราว ทดลองการบันทึกข้อมูลลง Hive
    /* if (box.isEmpty) {
      await box.putAll({
        'song1': SongModel(
          id: 'song1',
          title: "Daily Mix 1",
          artist: "Dua Lipa, Drake",
          artUri: "https://images.unsplash.com/photo-1514525253440-b393452e3726?auto=format&fit=crop&w=200&q=80",
          audioUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        ),
        'song2': SongModel(
          id: 'song2',
          title: "On Repeat",
          artist: "Songs you love",
          artUri: "https://images.unsplash.com/photo-1494232410401-ad00d5433cfa?auto=format&fit=crop&w=200&q=80",
          audioUrl: "https://www.dropbox.com/scl/fi/5wfwjk9779o4humsztoag/Ai-Scream-AiScReam-Lyrics-COLOR-CODED-LoveLive-Njma.mp3?rlkey=lg8zcz1wwlif0j0yrlvkjnvfq&st=rwheoyaj&dl=1",
        ),
        'song3': SongModel(
          id: 'song3',
          title: "Late Night",
          artist: "Soft instrumental",
          artUri: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=200&q=80",
          audioUrl: "https://www.dropbox.com/scl/fi/t51aanddts1x7ask85ek0/KATSEYE-Touch-Official-MV-HYBE-LABELS.mp3?rlkey=il4y00h7o484b83td0lfprv2o&st=t8lgi1za&dl=1",
        ),
        'song4': SongModel(
          id: 'song4',
          title: "Jazz Vibes",
          artist: "Smooth Jazz",
          artUri: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=200&q=80",
          audioUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3",
        ),
        'song5': SongModel(
          id: 'song5',
          title: "Rock Classics",
          artist: "The Legends",
          artUri: "https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?auto=format&fit=crop&w=200&q=80", 
          audioUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3", 
        ),
      });
    }
    */

    setState(() {
      _isHiveReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isHiveReady) {
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
              padding: const EdgeInsets.only(bottom: 140),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const _HomeHeader(),
                    const SizedBox(height: 20),
                    const _CategoryTabs(),
                    const SizedBox(height: 30),
                    
                    const SectionTitle(title: "New Releases"),
                    
                    const SizedBox(height: 15),
                    const _NewReleaseBanner(),
                    const SizedBox(height: 30),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SectionTitle(title: "Made for You"),
                        Icon(Icons.history, color: Colors.white.withOpacity(0.5)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                    const _MadeForYouList(),
                    
                    const SizedBox(height: 30),
                    const SectionTitle(title: "Explore Categories"),
                    const SizedBox(height: 15),
                    const _ExploreGrid(),
                  ],
                ),
              ),
            ),

            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  MiniPlayer(),
                  CustomBottomNavBar(selectedIndex: 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&q=80'),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Good Morning", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
            const Text("Alex Johnson", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const Spacer(),
        IconButton(icon: const Icon(Icons.notifications, color: Colors.white), onPressed: () {})
      ],
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs();
  @override
  Widget build(BuildContext context) {
    final categories = ["For You", "Music", "Podcasts", "Live Radio"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = category == "For You";
          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF8B2CF5) : const Color(0xFF2C2C35),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(category, style: TextStyle(color: isSelected ? Colors.white : Colors.white.withOpacity(0.6), fontWeight: FontWeight.bold)),
          );
        }).toList(),
      ),
    );
  }
}

class _NewReleaseBanner extends StatelessWidget {
  const _NewReleaseBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1493225255756-d9584f8606e9?auto=format&fit=crop&w=800&q=80'), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.8), Colors.transparent]),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(5)), child: const Text("EXCLUSIVE", style: TextStyle(color: Colors.white, fontSize: 10))),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Starboy Chronicles", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("The Weeknd • Hip-Hop", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
              Container(decoration: const BoxDecoration(color: Color(0xFF8B2CF5), shape: BoxShape.circle), child: IconButton(icon: const Icon(Icons.play_arrow, color: Colors.white), onPressed: () {}))
            ])
          ],
        ),
      ),
    );
  }
}


class _MadeForYouList extends StatelessWidget {
  const _MadeForYouList();

  @override
  Widget build(BuildContext context) {
    final audioHandler = GetIt.I<AudioHandler>();
    final box = Hive.box<SongModel>('home_songs');

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box<SongModel> songBox, _) {
        final songs = songBox.values.toList();

        return SizedBox(
          height: 200, 
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ), 
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return _buildItem(
                  context,
                  audioHandler,
                  title: song.title,
                  subtitle: song.artist,
                  imageUrl: song.artUri,
                  mp3Url: song.audioUrl,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildItem(
    BuildContext context,
    AudioHandler audioHandler, {
    required String title,
    required String subtitle,
    required String imageUrl,
    required String mp3Url,
  }) {
    return GestureDetector(
      onTap: () async {
        if (audioHandler is MyAudioHandler) {
          await audioHandler.loadSong(
            mp3Url, 
            title, 
            subtitle, 
            imageUrl
          );
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PlayerScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B2CF5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 140,
              child: Text(
                title, 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                maxLines: 1, 
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 140,
              child: Text(
                subtitle, 
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _ExploreGrid extends StatelessWidget {
  const _ExploreGrid();
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _buildCard("Podcasts", Colors.orange, Icons.mic),
        _buildCard("Live Events", const Color(0xFF7B61FF), Icons.local_activity),
        _buildCard("Charts", const Color(0xFFFF0055), Icons.show_chart),
        _buildCard("Focus", const Color(0xFFD07200), Icons.lightbulb),
      ],
    );
  }
  Widget _buildCard(String title, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(15),
      child: Stack(children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Positioned(bottom: -10, right: -10, child: Transform.rotate(angle: 0.5, child: Icon(icon, size: 60, color: Colors.white.withOpacity(0.3))))
      ]),
    );
  }
}
