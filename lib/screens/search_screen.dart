import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/music_provider.dart';
import '../widgets/song_tile.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();
    final results = music.searchResults;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: TextField(
              autofocus: false,
              onChanged: music.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search songs, artists, albums',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: const Color(0xFF262626),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: music.isLoading
                ? const Center(child: CircularProgressIndicator())
                : results.isEmpty
                    ? const Center(
                        child: Text(
                          'No matching local songs.',
                          style: TextStyle(color: Colors.white60),
                        ),
                      )
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (_, index) => SongTile(song: results[index]),
                      ),
          ),
        ],
      ),
    );
  }
}
