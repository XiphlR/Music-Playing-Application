import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/song_model.dart'; 

class UserHiveManager {
  static const _storage = FlutterSecureStorage();

  // ฟังก์ชันเปิดกล่อง Hive ประจำตัวผู้ใช้
  static Future<Box> getUserBox() async {
    String? username = await _storage.read(key: 'username');
    String boxName = 'user_data_${username ?? 'guest'}';
    
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }

  // ==========================================
  // ระบบหน้า Home & Search
  // ==========================================
  static Future<void> ensureInitialSongsLoaded() async {
    final box = await getUserBox();
    Map<dynamic, dynamic> currentSongs = box.get('home_songs', defaultValue: <dynamic, dynamic>{});

    if (currentSongs.isEmpty) {
      try {
        final String jsonString = await rootBundle.loadString('lib/data/song.json');
        final List<dynamic> jsonData = json.decode(jsonString); 
        
        final Map<String, SongModel> fetchedSongs = {};
        for (var item in jsonData) {
          final song = SongModel(
            id: item['id'].toString(),
            title: item['title'].toString(),
            artist: item['artist'].toString(),
            artUrl: item['artUrl'].toString(), 
            audioUrl: item['audioUrl'].toString(),
          );
          fetchedSongs[song.id] = song;
        }
        await box.put('home_songs', fetchedSongs); 
        debugPrint("✅ โหลดเพลงเริ่มต้นสำเร็จ ${fetchedSongs.length} เพลง");
      } catch (e) {
        debugPrint("❌ Error loading JSON: $e");
      }
    }
  }

  static Future<List<String>> getRecentSearches() async {
    final box = await getUserBox();
    final List<dynamic> rawList = box.get('recent_searches', defaultValue: <String>[]);
    return rawList.map((e) => e.toString()).toList();
  }

  static Future<void> saveRecentSearches(List<String> recents) async {
    final box = await getUserBox();
    await box.put('recent_searches', recents);
  }

  static Future<void> clearRecentSearches() async {
    final box = await getUserBox();
    await box.delete('recent_searches');
  }

  // ==========================================
  // A. ระบบ Favorite (การถูกใจ)
  // ==========================================
  static Future<List<SongModel>> getFavorites() async {
    var box = await getUserBox();
    var rawList = box.get('favorites_list', defaultValue: <dynamic>[]);
    return List<SongModel>.from(rawList);
  }

  static Future<void> toggleFavorite(SongModel song, bool isFav) async {
    var box = await getUserBox();
    List<SongModel> favs = await getFavorites();

    if (isFav) {
      if (!favs.any((s) => s.id == song.id)) favs.add(song);
    } else {
      favs.removeWhere((s) => s.id == song.id);
    }
    await box.put('favorites_list', favs);
  }

  static Future<bool> isFavorite(String songId) async {
    List<SongModel> favs = await getFavorites();
    return favs.any((s) => s.id == songId);
  }

  // ==========================================
  // B. ระบบ Recent Songs (3 เพลงล่าสุดที่เล่น)
  // ==========================================
  static Future<List<SongModel>> getRecentSongs() async {
    var box = await getUserBox();
    var rawList = box.get('recent_songs', defaultValue: <dynamic>[]);
    return List<SongModel>.from(rawList);
  }

  static Future<void> addRecentSong(SongModel song) async {
    var box = await getUserBox();
    List<SongModel> recents = await getRecentSongs();

    recents.removeWhere((s) => s.id == song.id); // ลบของเดิมถ้ามีซ้ำ
    recents.insert(0, song); // ดันขึ้นไปตำแหน่งแรกสุด

    if (recents.length > 3) recents = recents.sublist(0, 3); // เก็บแค่ 3 เพลง
    await box.put('recent_songs', recents);
  }

  // ==========================================
  // C. ระบบ Progress (เวลาที่ฟังค้างไว้)
  // ==========================================
  static Future<void> saveProgress(String songId, Duration position) async {
    var box = await getUserBox();
    await box.put('progress_$songId', position.inMilliseconds);
  }

  static Future<Duration> getProgress(String songId) async {
    var box = await getUserBox();
    int millis = box.get('progress_$songId', defaultValue: 0);
    return Duration(milliseconds: millis);
  }

  // ==========================================
  // D. ระบบ Current Song (เพลงปัจจุบัน)
  // ==========================================
  static Future<void> saveCurrentSong(SongModel song) async {
    var box = await getUserBox();
    await box.put('current_song', song);
  }

  static Future<SongModel?> getCurrentSong() async {
    var box = await getUserBox();
    return box.get('current_song') as SongModel?;
  }

  static Future<void> saveVolume(double volume) async {
    var box = await getUserBox();
    await box.put('user_volume', volume);
  }

  static Future<double> getVolume() async {
    var box = await getUserBox();
    return box.get('user_volume', defaultValue: 1.0); // ค่าเริ่มต้นคือดังสุด
  }
}

