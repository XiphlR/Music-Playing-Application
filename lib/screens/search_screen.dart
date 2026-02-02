import 'package:flutter/material.dart';
import 'player_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151521),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const _SearchHeader(),
                    const SizedBox(height: 15),
                    const _SearchBar(),
                    
                    const SizedBox(height: 15),
                    
                    const _FilterChips(),
                    
                    const SizedBox(height: 25),
                    
                    const _SectionHeader(title: "Recent searches", action: "CLEAR ALL"),
                    const SizedBox(height: 10),
                    const _RecentSearchesList(),
                    
                    const SizedBox(height: 25),
                    
                    const _SectionHeader(title: "Browse all"),
                    const SizedBox(height: 15),
                    const _BrowseAllGrid(),
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
                  const _MiniPlayerSearch(),
                  _buildBottomNavBar(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      color: const Color(0xFF151521),
      padding: const EdgeInsets.only(top: 10),
      child: BottomNavigationBar(
        backgroundColor: const Color(0xFF151521),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF8B2CF5),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          } else if (index == 3) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.library_music), label: "Library"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Search",
          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Artists, songs, or podcasts",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    final filters = ["All", "Artists", "Songs", "Podcasts", "Profiles"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == "All";
          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF8B2CF5) : const Color(0xFF2C2C35),
              borderRadius: BorderRadius.circular(20),
              border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Text(
              filter,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RecentSearchesList extends StatelessWidget {
  const _RecentSearchesList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRecentItem("Jane Doe", "Profile", "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&q=80", true),
        _buildRecentItem("The Daily Stoic", "Podcast", "https://images.unsplash.com/photo-1478737270239-2f02b77ac6d5?auto=format&fit=crop&w=100&q=80", false),
      ],
    );
  }

  Widget _buildRecentItem(String title, String subtitle, String imgUrl, bool isProfile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.close, color: Colors.white.withOpacity(0.5), size: 20),
        ],
      ),
    );
  }
}

class _BrowseAllGrid extends StatelessWidget {
  const _BrowseAllGrid();

  @override
  Widget build(BuildContext context) {
    final categories = [
      {"title": "Music", "color": const Color(0xFFFF0055), "image": "https://images.unsplash.com/photo-1493225255756-d9584f8606e9"},
      {"title": "Podcasts", "color": const Color(0xFF00BFA5), "image": "https://images.unsplash.com/photo-1478737270239-2f02b77ac6d5"},
      {"title": "Live Events", "color": const Color(0xFF536DFE), "image": "https://images.unsplash.com/photo-1501281668745-f7f57925c3b4"},
      {"title": "Made For You", "color": const Color(0xFF2979FF), "image": "https://images.unsplash.com/photo-1514525253440-b393452e3726"},
      {"title": "New Releases", "color": Colors.grey.shade700, "image": "https://images.unsplash.com/photo-1614850523060-8da1d56ae167"},
      {"title": "Charts", "color": const Color(0xFFAA00FF), "image": "https://images.unsplash.com/photo-1470225620780-dba8ba36b745"},
      {"title": "Focus", "color": const Color(0xFF00695C), "image": "https://images.unsplash.com/photo-1519681393784-d120267933ba"},
      {"title": "Mood", "color": const Color(0xFFFF6D00), "image": "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4"},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryCard(
          categories[index]["title"] as String,
          categories[index]["color"] as Color,
          categories[index]["image"] as String,
        );
      },
    );
  }

  Widget _buildCategoryCard(String title, Color color, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Positioned(
            right: -15,
            bottom: -10,
            child: Transform.rotate(
              angle: 0.4,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(-2, 2))
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  const _SectionHeader({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        if (action != null)
          Text(action!, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _MiniPlayerSearch extends StatelessWidget {
  const _MiniPlayerSearch();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PlayerScreen()));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF21212E),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1493225255756-d9584f8606e9?auto=format&fit=crop&w=100&q=80'),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Starboy", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text("The Weeknd", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white), onPressed: () {}),
            Container(
              decoration: const BoxDecoration(color: Color(0xFF8B2CF5), shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow, color: Colors.white),
            ),
            IconButton(icon: const Icon(Icons.skip_next, color: Colors.white), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
