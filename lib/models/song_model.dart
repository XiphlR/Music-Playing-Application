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
  late String artUrl;

  @HiveField(4)
  late String audioUrl;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.artUrl,
    required this.audioUrl,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
  return SongModel(
    id: json['id'].toString(),
    title: json['title'] ?? '',
    artist: json['artist'] ?? '',
    artUrl: json['artUrl'] ?? '',
    audioUrl: json['audioUrl'] ?? '',
  );
}
}
