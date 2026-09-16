import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/local_song.dart';
import '../providers/music_provider.dart';
import 'album_art.dart';

class SpeedDialGrid extends StatelessWidget {
  const SpeedDialGrid({super.key, required this.songs});

  final List<LocalSong> songs;

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            'No local songs found.',
            style: TextStyle(color: Colors.white60),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.83,
      ),
      itemBuilder: (context, index) {
        final song = songs[index];
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.read<MusicProvider>().playSong(song),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AlbumArt(
                  songId: song.id,
                  width: 260,
                  height: 260,
                  borderRadius: 0,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xCC000000),
                      ],
                      stops: [0.45, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Text(
                    song.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
