import 'package:flutter/material.dart';
import 'screens/player_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Player UI',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF151521),
        primaryColor: const Color(0xFF8B2CF5),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const PlayerScreen(),
    );
  }
}