import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import '../services/user_hive_manager.dart'; 
import '../models/song_model.dart'; 

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.music_player.channel.audio',
      androidNotificationChannelName: 'Music Player Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);
  
  // ตัวแปรล็อค Logic กันคิวเอ๋อ
  bool _isRemoving = false;

  MyAudioHandler() {
    _initPlayer();
    restoreUserSession();
    
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    // ดักฟังเวลาทั้งหมด
    _player.durationStream.listen((duration) {
      final item = mediaItem.value;
      if (item != null && duration != null) {
        mediaItem.add(item.copyWith(duration: duration));
      }
    });

    // ลบเฉพาะเพลงเก่า และป้องกันการลบสะบัดจนคิวหาย
    _player.currentIndexStream.listen((index) async {
      if (index != null && index > 0 && !_isRemoving) {
        _isRemoving = true; 
        try {
          await _playlist.removeAt(0);
          debugPrint("✅ ลบเพลงที่เล่นจบแล้วทิ้งอัตโนมัติ");
        } catch (e) {
          debugPrint("❌ Error auto-removing: $e");
        }
        _isRemoving = false; 
      }

      if (_playlist.length > 0) {
        final source = _playlist.children[0] as UriAudioSource;
        final item = source.tag as MediaItem;
        mediaItem.add(item.copyWith(duration: _player.duration));
      }
    });

    _player.positionStream.listen((position) {
      if (position.inSeconds > 0 && position.inSeconds % 5 == 0) _saveProgress();
    });
  }

  Future<void> _initPlayer() async {
    await _player.setAudioSource(_playlist);
  }

  Future<void> loadSong(String url, String title, String artist, String artUri) async {
    try {
      _isRemoving = true; 
      await _playlist.clear();
      final item = MediaItem(
        id: url, album: "Music Player", title: title, artist: artist,
        artUri: Uri.tryParse(artUri),
      );
      await _playlist.add(AudioSource.uri(Uri.parse(url), tag: item));
      
      final startPos = await UserHiveManager.getProgress(url);
      await _player.seek(startPos);
      await _player.play();
      await _saveProgress();
      _isRemoving = false;
    } catch (e) {
      _isRemoving = false;
      debugPrint("Error loading: $e");
    }
  }

  Future<void> addSongToQueue(SongModel song) async {
    final item = MediaItem(
      id: song.audioUrl, title: song.title, artist: song.artist, 
      artUri: Uri.tryParse(song.artUrl),
    );
    await _playlist.add(AudioSource.uri(Uri.parse(song.audioUrl), tag: item));
  }

  Future<void> clearQueue() async {
    if (_playlist.length > 1) {
      await _playlist.removeRange(1, _playlist.length);
    }
  }

  List<MediaItem> get currentQueue => _playlist.children
      .map((source) => (source as UriAudioSource).tag as MediaItem)
      .toList();

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
    await UserHiveManager.saveVolume(volume); 
  }

  Future<void> clearUserSession() async {
    await _player.stop();
    await _playlist.clear();
    mediaItem.add(null);
  }

  Future<void> restoreUserSession() async {
    try {
      final savedVolume = await UserHiveManager.getVolume();
      await _player.setVolume(savedVolume);
      final lastSong = await UserHiveManager.getCurrentSong();
      if (lastSong != null) {
        await loadSong(lastSong.audioUrl, lastSong.title, lastSong.artist, lastSong.artUrl);
        await _player.pause(); 
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Future<void> play() => _player.play();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> stop() async { await _saveProgress(); await _player.stop(); }
  @override
  Future<void> seek(Duration position) => _player.seek(position);
  @override
  Future<void> skipToNext() => _player.seekToNext();
  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  Future<void> toggleRepeat() async {
    await _player.setLoopMode(_player.loopMode == LoopMode.off ? LoopMode.one : LoopMode.off);
  }

  Stream<LoopMode> get loopModeStream => _player.loopModeStream;

  Future<void> _saveProgress() async {
    if (mediaItem.value != null) {
      final item = mediaItem.value!;
      final song = SongModel(
        id: item.id, title: item.title, artist: item.artist ?? '',
        artUrl: item.artUri?.toString() ?? '', audioUrl: item.id,
      );
      await UserHiveManager.saveCurrentSong(song);
      await UserHiveManager.saveProgress(item.id, _player.position);
    }
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {MediaAction.seek, MediaAction.seekForward, MediaAction.seekBackward},
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
