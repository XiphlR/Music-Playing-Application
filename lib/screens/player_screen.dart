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

  Future<void> _initUserPlayer() async {
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
        await _audioHandler.addQueueItem(mediaItem);
      }
    } catch (e) {
      debugPrint("Error loading last song: $e");
    }

    _audioHandler.mediaItem.listen((mediaItem) async {
      if (mediaItem != null) {
        final currentSongModel = SongModel(
          id: mediaItem.id,
          title: mediaItem.title,
          artist: mediaItem.artist ?? 'Unknown Artist',
          artUrl: mediaItem.artUri?.toString() ?? '',
          audioUrl: mediaItem.extras?['audioUrl'] ?? mediaItem.id,
        );
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
                  Hero(
                    tag: 'album_art',
                    child: AlbumArt(artUri: mediaItem.artUri?.toString()),
                  ),
                  const SizedBox(height: 30),
                  Hero(
                    tag: 'song_title',
                    child: Material(
                      color: Colors.transparent,
                      child: SongInfoSection(song: currentSongModel),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // --- ส่วนควบคุมการเล่นเพลง ---
                  StreamBuilder<PlaybackState>(
                    stream: _audioHandler.playbackState,
                    builder: (context, stateSnapshot) {
                      final state = stateSnapshot.data;
                      final playing = state?.playing ?? false;
                      final duration = mediaItem.duration ?? Duration.zero;
                      
                      // ดึงสถานะ Shuffle จาก PlaybackState
                      final isShuffle = state?.shuffleMode == AudioServiceShuffleMode.all;

                      return Column(
                        children: [
                          // Progress Bar
                          StreamBuilder<Duration>(
                            stream: AudioService.position,
                            builder: (context, positionSnapshot) {
                              final currentPos = positionSnapshot.data ?? (state?.position ?? Duration.zero);
                              return ProgressBarSection(
                                currentPosition: currentPos,
                                totalDuration: duration,
                                onSeek: (newPosition) => _audioHandler.seek(newPosition),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          
                          // Playback Controls
                          StreamBuilder<LoopMode>(
                            stream: (_audioHandler as MyAudioHandler).loopModeStream,
                            builder: (context, loopSnapshot) {
                              final currentLoop = loopSnapshot.data ?? LoopMode.off;
                              final isRepeatOne = currentLoop == LoopMode.one;

                              return PlaybackControls(
                                isPlaying: playing,
                                isRepeat: isRepeatOne,
                                isShuffle: isShuffle,
                                onPlayPause: () => playing ? _audioHandler.pause() : _audioHandler.play(),
                                onNext: () => _audioHandler.skipToNext(),
                                onPrevious: () => _audioHandler.skipToPrevious(),
                                onRepeat: () => (_audioHandler).toggleRepeat(),
                                // 🌟 ฟังก์ชันสลับโหมด Shuffle
                                onShuffle: () {
                                  _audioHandler.setShuffleMode(
                                    isShuffle ? AudioServiceShuffleMode.none : AudioServiceShuffleMode.all
                                  );
                                },
                              );
                            },
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
