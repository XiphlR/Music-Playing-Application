import 'package:flutter/material.dart';
import 'player_screen.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151521),
      body: SafeArea(
        child: Stack(
          children: [
            // --- ส่วนเนื้อหา (Scrollable) ---
            SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 160),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  const _ProfileAppBar(),
                  
                  const SizedBox(height: 20),

                  const _UserInfoSection(),
                  
                  const SizedBox(height: 30),

                  const _SectionHeader(title: "Jump Back In", action: "View All"),
                  const SizedBox(height: 15),
                  const _JumpBackInList(),
                  
                  const SizedBox(height: 30),
                  
                  const _SectionHeader(title: "Your Favorites"),
                  const SizedBox(height: 10),
                  const _FavoritesList(),
                  
                  const SizedBox(height: 30),
                  
                  const _SectionHeader(title: "Account"),
                  const SizedBox(height: 15),
                  const _LogoutButton(),
                ],
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const _MiniPlayerProfile(),
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
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


class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {},
            ),
          ],
        )
      ],
    );
  }
}

class _UserInfoSection extends StatelessWidget {
  const _UserInfoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B2CF5).withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80'),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          "Jane Doe",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
            children: const [
              TextSpan(text: "@janedoe • "),
              TextSpan(
                text: "Premium",
                style: TextStyle(color: Color(0xFF8B2CF5), fontWeight: FontWeight.bold),
              ),
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
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C35),
                borderRadius: BorderRadius.circular(30),
              ),
              child: IconButton(
                icon: const Icon(Icons.qr_code, color: Colors.white),
                onPressed: () {},
              ),
            )
          ],
        )
      ],
    );
  }
}

class _JumpBackInList extends StatelessWidget {
  const _JumpBackInList();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCard("Daily Mix 1", "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=200&q=80"),
          _buildCard("Lo-Fi Beats", "https://images.unsplash.com/photo-1516280440614-6697288d5d38?auto=format&fit=crop&w=200&q=80"),
          _buildCard("Top Hits", "https://images.unsplash.com/photo-1493225255756-d9584f8606e9?auto=format&fit=crop&w=200&q=80"),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      width: 110,
      child: Column(
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  const _FavoritesList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildListItem("Midnight City", "M83 • Hurry Up, We're Dreaming", "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=100&q=80"),
        _buildListItem("The Daily Stoic", "Ryan Holiday • Episode #42", "https://images.unsplash.com/photo-1478737270239-2f02b77ac6d5?auto=format&fit=crop&w=100&q=80"),
        _buildListItem("Bohemian Rhapsody", "Queen • A Night at the Opera", "https://images.unsplash.com/photo-1501612780327-45045538702b?auto=format&fit=crop&w=100&q=80"),
      ],
    );
  }

  Widget _buildListItem(String title, String subtitle, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.favorite, color: Color(0xFF8B2CF5), size: 20), onPressed: () {}),
          Icon(Icons.more_vert, color: Colors.white.withOpacity(0.5), size: 20),
        ],
      ),
    );
  }
}


class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(action!, style: const TextStyle(color: Color(0xFF8B2CF5), fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _MiniPlayerProfile extends StatelessWidget {
  const _MiniPlayerProfile();

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
                  Text("The Weeknd, Daft Punk", style: TextStyle(color: Colors.grey, fontSize: 12)),
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
