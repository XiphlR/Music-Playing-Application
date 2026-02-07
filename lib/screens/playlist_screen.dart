import 'package:flutter/material.dart';
import '../widgets/app_widgets.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  bool isQueueSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151521),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const _LibraryHeader(),
                    
                    const SizedBox(height: 20),
                    
                    _buildToggleSwitch(),
                    
                    const SizedBox(height: 30),
                    
                    if (isQueueSelected) ...[
                      const Text(
                        "NOW PLAYING",
                        style: TextStyle(
                            color: Color(0xFF8B2CF5),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 15),
                      const _NowPlayingCard(),
                      
                      const SizedBox(height: 30),
                      
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Up Next", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("Clear Queue", style: TextStyle(color: Color(0xFF8B2CF5), fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      
                      const _UpNextList(),
                      
                      const SizedBox(height: 20),
                      
                      _buildAddMusicButton(),
                    ],
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  if (isQueueSelected) const _FloatingControlPanel(),
                  const SizedBox(height: 10),
                  const CustomBottomNavBar(selectedIndex: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C35),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isQueueSelected = true),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isQueueSelected ? const Color(0xFF8B2CF5) : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Queue",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isQueueSelected = false),
                  child: Container(
                    decoration: BoxDecoration(
                      color: !isQueueSelected ? const Color(0xFF8B2CF5) : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Playlists",
                      style: TextStyle(
                        color: !isQueueSelected ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddMusicButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2), style: BorderStyle.solid),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.add, size: 16, color: Colors.black),
            ),
            const SizedBox(width: 10),
            const Text("Add Music", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// --- Widgets เฉพาะของหน้า Playlist ---

class _LibraryHeader extends StatelessWidget {
  const _LibraryHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        const Text(
          "Library",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: const Text("Edit", style: TextStyle(color: Color(0xFF8B2CF5), fontWeight: FontWeight.bold)),
        )
      ],
    );
  }
}

class _NowPlayingCard extends StatelessWidget {
  const _NowPlayingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C35).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B2CF5).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B2CF5).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=100&q=80'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Midnight City", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text("M83 • Hurry Up, We're Dreaming", style: TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: Color(0xFF8B2CF5), shape: BoxShape.circle),
            child: const Icon(Icons.pause, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _UpNextList extends StatelessWidget {
  const _UpNextList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildListItem("Waves", "Kanye West", "https://images.unsplash.com/photo-1439405326854-014607f694d7?auto=format&fit=crop&w=100&q=80"),
        _buildListItem("Blinding Lights", "The Weeknd", "https://images.unsplash.com/photo-1614850523060-8da1d56ae167?auto=format&fit=crop&w=100&q=80"),
        _buildListItem("Someone Like You", "Adele", "https://images.unsplash.com/photo-1493225255756-d9584f8606e9?auto=format&fit=crop&w=100&q=80"),
        _buildListItem("Starboy", "The Weeknd, Daft Punk", "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=100&q=80"),
      ],
    );
  }

  Widget _buildListItem(String title, String artist, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(imageUrl, width: 55, height: 55, fit: BoxFit.cover),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(artist, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.more_horiz, color: Colors.white.withOpacity(0.3)),
          const SizedBox(width: 15),
          Icon(Icons.drag_handle, color: Colors.white.withOpacity(0.3)),
        ],
      ),
    );
  }
}

class _FloatingControlPanel extends StatelessWidget {
  const _FloatingControlPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C35),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.shuffle, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.repeat, color: Colors.white),
            onPressed: () {},
          ),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B2CF5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            icon: const Icon(Icons.save, size: 18, color: Colors.white),
            label: const Text("Save as Playlist", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          )
        ],
      ),
    );
  }
}
