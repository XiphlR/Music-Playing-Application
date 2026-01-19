import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';

import '../widgets/player_widgets.dart';
import '../services/audio_handler.dart'; 

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
    if (_audioHandler is MyAudioHandler) {
      (_audioHandler).loadSong(
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        "The Future of UI",
        "Design Matters Podcast",
        "https://images.unsplash.com/photo-1614850523060-8da1d56ae167"
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: StreamBuilder<MediaItem?>(
            stream: _audioHandler.mediaItem,
            builder: (context, snapshot) {
              final mediaItem = snapshot.data;

              if (mediaItem == null) {
                return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
              }

              return Column(
                children: [
                  const TopNavBar(),
                  const SizedBox(height: 30),
                  AlbumArt(artUri: mediaItem.artUri?.toString()),
                  const SizedBox(height: 30),
                  SongInfoSection(
                    title: mediaItem.title,
                    artist: mediaItem.artist ?? '',
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
                                // สั่ง Toggle Repeat
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
