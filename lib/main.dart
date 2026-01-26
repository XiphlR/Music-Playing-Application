import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';

import 'services/audio_handler.dart'; 
//import 'screens/player_screen.dart';
//import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';

final getIt = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final audioHandler = await initAudioService();
  getIt.registerSingleton<AudioHandler>(audioHandler);

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
      ),
      home: const ProfileScreen(),
    );
  }
}
