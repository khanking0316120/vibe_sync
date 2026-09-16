import 'package:on_audio_query_pluse/on_audio_query.dart';

class LocalSong {
  const LocalSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.data,
    required this.uri,
    required this.duration,
    required this.albumId,
  });

  final int id;
  final String title;
  final String artist;
  final String album;
  final String data;
  final String? uri;
  final Duration duration;
  final int? albumId;

  String get playableUri {
    final candidate = uri?.trim();
    if (candidate != null && candidate.isNotEmpty) {
      return candidate;
    }
    return Uri.file(data).toString();
  }

  Uri? get artworkUri {
    final id = albumId;
    if (id == null || id <= 0) return null;
    return Uri.parse('content://media/external/audio/albumart/$id');
  }

  factory LocalSong.fromSongModel(SongModel song) {
    String clean(String? value, String fallback) {
      final text = value?.trim() ?? '';
      if (text.isEmpty || text.toLowerCase() == '<unknown>') return fallback;
      return text;
    }

    return LocalSong(
      id: song.id,
      title: clean(song.title, song.displayNameWOExt),
      artist: clean(song.artist, 'Unknown artist'),
      album: clean(song.album, 'Unknown album'),
      data: song.data,
      uri: song.uri,
      duration: Duration(milliseconds: song.duration ?? 0),
      albumId: song.albumId,
    );
  }
}
