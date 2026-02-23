import 'package:hive/hive.dart';

part 'song_model.g.dart'; 

@HiveType(typeId: 0)
class SongModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String artist;

  @HiveField(3)
  late String artUri;

  @HiveField(4)
  late String audioUrl;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.artUri,
    required this.audioUrl,
  });
}
