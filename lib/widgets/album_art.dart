import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';

class AlbumArt extends StatelessWidget {
  const AlbumArt({
    super.key,
    required this.songId,
    this.width = 56,
    this.height = 56,
    this.borderRadius = 4,
  });

  final int songId;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.music_note_rounded,
        size: width * 0.38,
        color: Colors.white70,
      ),
    );

    return QueryArtworkWidget(
      id: songId,
      type: ArtworkType.AUDIO,
      quality: 100,
      size: 600,
      artworkWidth: width,
      artworkHeight: height,
      artworkFit: BoxFit.cover,
      artworkBorder: BorderRadius.circular(borderRadius),
      keepOldArtwork: true,
      nullArtworkWidget: fallback,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}
