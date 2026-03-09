import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';

import '../widgets/player_widgets.dart';
import '../services/audio_handler.dart'; 
import '../services/user_hive_manager.dart';
import '../models/song_model.dart';



class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final _audioHandler = GetIt.I<AudioHandler>();

  @override
  void initState() {
    super.initState();
    _initUserPlayer(); 
  }

  // ==========================================
  // ฟังก์ชันดึงเพลงล่าสุดและดักเซฟเพลงแยกตาม User
  // ==========================================
  Future<void> _initUserPlayer() async {
    // 1. ลองดึงเพลงที่เคยฟังค้างไว้ (Fail-safe เผื่อ audio_handler โหลดไม่ทัน)
    try {
      final lastSong = await UserHiveManager.getCurrentSong();
      
      if (lastSong != null && _audioHandler.mediaItem.value == null) {
        final mediaItem = MediaItem(
          id: lastSong.id,
          title: lastSong.title,
          artist: lastSong.artist,
          artUri: Uri.parse(lastSong.artUrl),
          extras: {'audioUrl': lastSong.audioUrl},
        );
        
        // ยัดข้อมูลเข้า Audio Service ให้ UI แสดงผล
        await _audioHandler.addQueueItem(mediaItem);
        
        // หมายเหตุ: กรณีใช้ MyAudioHandler ที่เราทำไว้ มันจะโหลดเพลงขึ้นมาเองอยู่แล้ว 
        // โค้ดก้อนนี้ทำหน้าที่เป็นตัวสำรองกันเหนียวครับ
      }
    } catch (e) {
      debugPrint("Error loading last song: $e");
    }

    // 2. แอบดักฟังเพื่อเซฟเพลงลงลิสต์ "ประวัติ 3 เพลงล่าสุด" อัตโนมัติเวลาเปลี่ยนเพลง
    _audioHandler.mediaItem.listen((mediaItem) async {
      if (mediaItem != null) {
        final currentSongModel = SongModel(
          id: mediaItem.id, // ใช้ ID เพลง
          title: mediaItem.title,
          artist: mediaItem.artist ?? 'Unknown Artist',
          artUrl: mediaItem.artUri?.toString() ?? '',
          audioUrl: mediaItem.extras?['audioUrl'] ?? mediaItem.id, // ดึงจาก extras หรือ id
        );
        
        // 🌟 บันทึกลง Recent Songs ส่วน Current Song ปล่อยให้ Audio Handler จัดการครับ
        await UserHiveManager.addRecentSong(currentSongModel);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151521), 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: StreamBuilder<MediaItem?>(
            stream: _audioHandler.mediaItem,
            builder: (context, snapshot) {
              final mediaItem = snapshot.data;
              if (mediaItem == null) {
                // 🌟 แก้ตัวแปรสีตรงนี้ให้เป็น Hex Color ตรงๆ ป้องกัน Error หาไม่เจอ
                return const Center(child: CircularProgressIndicator(color: Color(0xFF8B2CF5)));
              }

              final currentSongModel = SongModel(
                id: mediaItem.id,
                title: mediaItem.title,
                artist: mediaItem.artist ?? 'Unknown Artist',
                artUrl: mediaItem.artUri?.toString() ?? '',
                audioUrl: mediaItem.extras?['audioUrl'] ?? mediaItem.id,
              );

              return Column(
                children: [
                  const TopNavBar(), 
                  const SizedBox(height: 30),
                  
                  // รูปปก
                  Hero(
                    tag: 'album_art',
                    child: AlbumArt(artUri: mediaItem.artUri?.toString()),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // ชื่อเพลง
                  Hero(
                    tag: 'song_title',
                    child: Material(
                      color: Colors.transparent,
                      child: SongInfoSection(song: currentSongModel),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  StreamBuilder<PlaybackState>(
                    stream: _audioHandler.playbackState,
                    builder: (context, stateSnapshot) {
                      final state = stateSnapshot.data;
                      final playing = state?.playing ?? false;
                      final position = state?.position ?? Duration.zero;
                      final duration = mediaItem.duration ?? Duration.zero;

                      return Column(
                        children: [
                          // Progress Bar
                          StreamBuilder<Duration>(
                            stream: AudioService.position,
                            builder: (context, positionSnapshot) {
                              final currentPos = positionSnapshot.data ?? position;
                              return ProgressBarSection(
                                currentPosition: currentPos,
                                totalDuration: duration,
                                onSeek: (newPosition) {
                                  _audioHandler.seek(newPosition);
                                },
                              );
                            },
                          ),
                          
                          const SizedBox(height: 10),
                          
                          StreamBuilder<LoopMode>(
                            stream: (_audioHandler as MyAudioHandler).loopModeStream,
                            builder: (context, loopSnapshot) {
                              final currentLoop = loopSnapshot.data ?? LoopMode.off;
                              final isRepeatOne = currentLoop == LoopMode.one;

                              return PlaybackControls(
                                isPlaying: playing,
                                isRepeat: isRepeatOne,
                                onPlayPause: () {
                                  if (playing) {
                                    _audioHandler.pause();
                                  } else {
                                    _audioHandler.play();
                                  }
                                },
                                onNext: () => _audioHandler.skipToNext(),
                                onPrevious: () => _audioHandler.skipToPrevious(),
                                onRepeat: () => (_audioHandler).toggleRepeat(),
                              );
                            }
                          ),
                        ],
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  const VolumeControl(),
                  const Spacer(),
                  const BottomPlayerNav(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
