import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/local_song.dart';
import '../providers/music_provider.dart';
import 'album_art.dart';

class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    this.showTrailing = true,
  });

  final LocalSong song;
  final bool showTrailing;

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();
    final active = music.currentSong?.id == song.id;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () => context.read<MusicProvider>().playSong(song),
      leading: AlbumArt(songId: song.id, width: 52, height: 52),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: active ? Theme.of(context).colorScheme.primary : Colors.white,
          fontWeight: active ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${song.artist} • ${song.album}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white60),
      ),
      trailing: showTrailing
          ? IconButton(
              onPressed: () => _showActions(context),
              icon: const Icon(Icons.more_vert_rounded),
            )
          : null,
    );
  }

  void _showActions(BuildContext context) {
    final music = context.read<MusicProvider>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF252525),
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.play_arrow_rounded),
                title: const Text('Play'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  music.playSong(song);
                },
              ),
              ListTile(
                leading: Icon(
                  music.isSaved(song.id)
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                ),
                title: Text(
                  music.isSaved(song.id) ? 'Remove from library' : 'Save to library',
                ),
                onTap: () {
                  music.toggleSave(song.id);
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
