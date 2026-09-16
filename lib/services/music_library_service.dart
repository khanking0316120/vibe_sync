import 'package:on_audio_query_pluse/on_audio_query.dart';

import '../models/local_song.dart';

class MusicLibraryService {
  MusicLibraryService({OnAudioQuery? query}) : _query = query ?? OnAudioQuery();

  final OnAudioQuery _query;

  Future<bool> requestLibraryPermission() {
    return _query.checkAndRequest(retryRequest: true);
  }

  Future<List<LocalSong>> loadSongs() async {
    final rawSongs = await _query.querySongs();
    final songs = rawSongs.map(LocalSong.fromSongModel).toList(growable: false);

    songs.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
    return songs;
  }
}
