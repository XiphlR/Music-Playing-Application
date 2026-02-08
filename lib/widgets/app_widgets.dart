import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/playlist_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/player_screen.dart';


const Color kPrimaryColor = Color(0xFF8B2CF5);


class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            reverseTransitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) => const PlayerScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Hero(
              tag: 'album_art', 
              child: const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1614850523060-8da1d56ae167'),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: 'song_title',
                    child: Material(
                      color: Colors.transparent,
                      child: const Text(
                        "Blinding Lights", 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                  const Text("The Weeknd", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.devices, color: Colors.grey, size: 20), onPressed: () {}),
            IconButton(icon: const Icon(Icons.play_arrow, color: Colors.white), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}


class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  
  const CustomBottomNavBar({
    super.key, 
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF151521),
      padding: const EdgeInsets.only(top: 10),
      child: BottomNavigationBar(
        backgroundColor: const Color(0xFF151521),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: (index) {
          if (index == selectedIndex) return;

          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          } else if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SearchScreen()));
          } else if (index == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PlaylistScreen()));
          } else if (index == 3) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.library_music), label: "Library"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
