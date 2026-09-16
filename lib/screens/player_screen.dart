import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/music_provider.dart';
import '../utils/duration_format.dart';
import '../widgets/action_pill.dart';
import '../widgets/album_art.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();
    final song = music.currentSong;

    if (song == null) {
      return const Scaffold(
        body: Center(
          child: Text('Choose a song to start playing.'),
        ),
      );
    }

    final maxMs = music.duration.inMilliseconds;
    final positionMs = music.position.inMilliseconds
        .clamp(0, maxMs <= 0 ? 0 : maxMs)
        .toInt();
    final sliderMax = maxMs <= 0 ? 1.0 : maxMs.toDouble();
    final sliderValue = positionMs.toDouble().clamp(0.0, sliderMax).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFF150B0B),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 34),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.black38,
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: Colors.white12,
                          child: Icon(Icons.headphones_rounded, size: 19),
                        ),
                        SizedBox(width: 8),
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: Colors.transparent,
                          child: Icon(Icons.ondemand_video_outlined, size: 19),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.cast_rounded)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final size = constraints.maxWidth.clamp(240.0, 520.0).toDouble();
                        return AlbumArt(
                          songId: song.id,
                          width: size,
                          height: size,
                          borderRadius: 10,
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        song.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ActionPill(
                            icon: music.isLiked(song.id)
                                ? Icons.thumb_up_alt_rounded
                                : Icons.thumb_up_alt_outlined,
                            label: 'Like',
                            active: music.isLiked(song.id),
                            onTap: () => music.toggleLike(song.id),
                          ),
                          const SizedBox(width: 8),
                          ActionPill(
                            icon: music.isDisliked(song.id)
                                ? Icons.thumb_down_alt_rounded
                                : Icons.thumb_down_alt_outlined,
                            label: 'Dislike',
                            active: music.isDisliked(song.id),
                            onTap: () => music.toggleDislike(song.id),
                          ),
                          const SizedBox(width: 8),
                          ActionPill(
                            icon: Icons.lyrics_outlined,
                            label: 'Lyrics',
                            onTap: () => _showLocalOnlyInfo(
                              context,
                              'Lyrics',
                              'Embedded lyrics are not exposed by the selected local-media package.',
                            ),
                          ),
                          const SizedBox(width: 8),
                          ActionPill(
                            icon: Icons.comment_outlined,
                            label: 'Comments',
                            onTap: () => _showLocalOnlyInfo(
                              context,
                              'Comments',
                              'Comments require an online service and are disabled in local-only mode.',
                            ),
                          ),
                          const SizedBox(width: 8),
                          ActionPill(
                            icon: music.isSaved(song.id)
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            label: music.isSaved(song.id) ? 'Saved' : 'Save',
                            active: music.isSaved(song.id),
                            onTap: () => music.toggleSave(song.id),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Slider(
                      min: 0,
                      max: sliderMax,
                      value: sliderValue,
                      onChanged: (value) {
                        music.seek(Duration(milliseconds: value.round()));
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Row(
                        children: [
                          Text(
                            formatDuration(music.position),
                            style: const TextStyle(color: Colors.white60),
                          ),
                          const Spacer(),
                          Text(
                            formatDuration(music.duration),
                            style: const TextStyle(color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          tooltip: 'Shuffle',
                          onPressed: music.toggleShuffle,
                          color: music.shuffleEnabled ? Colors.white : Colors.white60,
                          icon: const Icon(Icons.shuffle_rounded, size: 30),
                        ),
                        IconButton(
                          tooltip: 'Previous',
                          onPressed: music.previous,
                          icon: const Icon(Icons.skip_previous_rounded, size: 48),
                        ),
                        Container(
                          width: 82,
                          height: 82,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: music.isBuffering
                              ? const Padding(
                                  padding: EdgeInsets.all(25),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.black,
                                  ),
                                )
                              : IconButton(
                                  tooltip: music.isPlaying ? 'Pause' : 'Play',
                                  onPressed: music.togglePlayPause,
                                  icon: Icon(
                                    music.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 50,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                        IconButton(
                          tooltip: 'Next',
                          onPressed: music.next,
                          icon: const Icon(Icons.skip_next_rounded, size: 48),
                        ),
                        IconButton(
                          tooltip: 'Repeat',
                          onPressed: music.cycleRepeatMode,
                          color: music.repeatMode == AudioServiceRepeatMode.none
                              ? Colors.white60
                              : Colors.white,
                          icon: Icon(
                            music.repeatMode == AudioServiceRepeatMode.one
                                ? Icons.repeat_one_rounded
                                : Icons.repeat_rounded,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: 64,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Local music',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocalOnlyInfo(BuildContext context, String title, String message) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF252525),
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(message, style: const TextStyle(color: Colors.white70, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
