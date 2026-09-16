import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/local_song.dart';
import '../providers/music_provider.dart';
import '../widgets/song_tile.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();

    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Library',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh library',
                    onPressed: music.refreshLibrary,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ),
            const TabBar(
              tabs: [
                Tab(text: 'Songs'),
                Tab(text: 'Saved'),
              ],
            ),
            Expanded(
              child: music.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        _SongList(
                          songs: music.songs,
                          emptyMessage: 'No local songs found.',
                        ),
                        _SongList(
                          songs: music.savedSongs,
                          emptyMessage: 'Songs you save will appear here.',
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SongList extends StatelessWidget {
  const _SongList({required this.songs, required this.emptyMessage});

  final List<LocalSong> songs;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(color: Colors.white60),
        ),
      );
    }

    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (_, index) => SongTile(song: songs[index]),
    );
  }
}
