String formatDuration(Duration duration) {
  final totalSeconds = duration.inSeconds.clamp(0, 359999).toInt();
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
