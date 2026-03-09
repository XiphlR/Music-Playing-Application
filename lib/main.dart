import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'services/audio_handler.dart'; 
import 'models/song_model.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';

final getIt = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter(); 
  Hive.registerAdapter(SongModelAdapter());
  await Hive.openBox<SongModel>('home_songs');
  await Hive.openBox<SongModel>('favorites');

  final audioHandler = await initAudioService();
  getIt.registerSingleton<AudioHandler>(audioHandler);

  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'token');
  bool isLoggedIn = (token != null);

  runApp(MyApp(isLoggedIn: isLoggedIn));
}


class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MyApp({super.key, required this.isLoggedIn});

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
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
