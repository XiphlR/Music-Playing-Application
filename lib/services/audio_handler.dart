import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.music_player.channel.audio',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer(); // ตัวเล่นเพลงหลัก

  MyAudioHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    _player.durationStream.listen((duration) {
      if (duration != null) {
        final currentItem = mediaItem.value;
        if (currentItem != null) {
          final newItem = currentItem.copyWith(duration: duration);
          mediaItem.add(newItem); 
        }
      }
    });
  }


  Stream<LoopMode> get loopModeStream => _player.loopModeStream;

  Future<void> toggleRepeat() async {
    final currentMode = _player.loopMode;
    if (currentMode == LoopMode.off) {
      await _player.setLoopMode(LoopMode.one); // เปิดวนซ้ำเพลงเดียว
    } else {
      await _player.setLoopMode(LoopMode.off); // ปิดวนซ้ำ
    }
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
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

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  // ฟังก์ชันปรับเสียง
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  // ฟังก์ชันโหลดเพลง
  Future<void> loadSong(String url, String title, String artist, String artUri) async {
    final item = MediaItem(
      id: url,
      album: "Music Player",
      title: title,
      artist: artist,
      artUri: Uri.parse(artUri),
      duration: null, 
    );
    
    mediaItem.add(item);
    
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      _player.play();
    } catch (e) {
      print("Error loading song: $e");
    }
  }
}
