import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class AppAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  AppAudioHandler() {
    _player.playbackEventStream.listen(_broadcastState);
    _player.currentIndexStream.listen(_onCurrentIndexChanged);
    _player.errorStream.listen((error) {
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.error,
          playing: false,
          errorCode: error.code,
          errorMessage: error.message,
        ),
      );
    });
  }

  final AudioPlayer _player = AudioPlayer(maxSkipsOnError: 3);

  Future<void> configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
  }

  Future<void> loadQueueAndPlay(
    List<MediaItem> items, {
    required int initialIndex,
  }) async {
    if (items.isEmpty) return;
    final safeIndex = initialIndex.clamp(0, items.length - 1).toInt();

    queue.add(List.unmodifiable(items));

    final sources = items
        .map(
          (item) => AudioSource.uri(
            Uri.parse(item.id),
            tag: item,
          ),
        )
        .toList(growable: false);

    await _player.setAudioSources(
      sources,
      initialIndex: safeIndex,
      initialPosition: Duration.zero,
    );

    mediaItem.add(items[safeIndex]);
    await play();
  }

  @override
  Future<void> play() async {
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(
        Duration.zero,
        index: _player.currentIndex ?? 0,
      );
    }
    await _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    final items = queue.value;
    if (index < 0 || index >= items.length) return;
    await _player.seek(Duration.zero, index: index);
    mediaItem.add(items[index]);
  }

  @override
  Future<void> skipToNext() async {
    await _player.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.position > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
      return;
    }
    await _player.seekToPrevious();
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode != AudioServiceShuffleMode.none;
    if (enabled) {
      await _player.shuffle();
    }
    await _player.setShuffleModeEnabled(enabled);
    playbackState.add(
      playbackState.value.copyWith(shuffleMode: shuffleMode),
    );
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    final loopMode = switch (repeatMode) {
      AudioServiceRepeatMode.one => LoopMode.one,
      AudioServiceRepeatMode.all => LoopMode.all,
      AudioServiceRepeatMode.group => LoopMode.all,
      AudioServiceRepeatMode.none => LoopMode.off,
    };

    await _player.setLoopMode(loopMode);
    playbackState.add(
      playbackState.value.copyWith(repeatMode: repeatMode),
    );
  }

  void _onCurrentIndexChanged(int? index) {
    if (index == null) return;
    final items = queue.value;
    if (index >= 0 && index < items.length) {
      mediaItem.add(items[index]);
    }
  }

  void _broadcastState(PlaybackEvent event) {
    final processingState = switch (_player.processingState) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    };

    final oldState = playbackState.value;
    playbackState.add(
      oldState.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (_player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: processingState,
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _player.currentIndex,
      ),
    );
  }
}
