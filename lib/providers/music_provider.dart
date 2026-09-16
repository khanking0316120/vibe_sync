import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

import '../models/local_song.dart';
import '../services/app_audio_handler.dart';
import '../services/music_library_service.dart';

class MusicProvider extends ChangeNotifier {
  MusicProvider({
    required AppAudioHandler audioHandler,
    required MusicLibraryService libraryService,
  })  : _audioHandler = audioHandler,
        _libraryService = libraryService {
    _subscriptions.add(
      _audioHandler.mediaItem.listen(_handleMediaItem),
    );
    _subscriptions.add(
      _audioHandler.playbackState.listen(_handlePlaybackState),
    );
    _subscriptions.add(
      AudioService.position.listen((value) {
        _position = value;
        notifyListeners();
      }),
    );
  }

  final AppAudioHandler _audioHandler;
  final MusicLibraryService _libraryService;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  List<LocalSong> _songs = const [];
  LocalSong? _currentSong;
  Duration _position = Duration.zero;
  bool _isLoading = false;
  bool _permissionDenied = false;
  String? _errorMessage;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _queueLoaded = false;
  bool _shuffleEnabled = false;
  AudioServiceRepeatMode _repeatMode = AudioServiceRepeatMode.none;
  String _searchQuery = '';
  String _selectedMood = 'Energize';

  final Set<int> _likedSongIds = <int>{};
  final Set<int> _dislikedSongIds = <int>{};
  final Set<int> _savedSongIds = <int>{};

  List<LocalSong> get songs => _songs;
  LocalSong? get currentSong => _currentSong;
  Duration get position => _position;
  Duration get duration => _currentSong?.duration ?? Duration.zero;
  bool get isLoading => _isLoading;
  bool get permissionDenied => _permissionDenied;
  String? get errorMessage => _errorMessage;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  bool get shuffleEnabled => _shuffleEnabled;
  AudioServiceRepeatMode get repeatMode => _repeatMode;
  String get selectedMood => _selectedMood;

  List<LocalSong> get searchResults {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _songs;
    return _songs.where((song) {
      return song.title.toLowerCase().contains(query) ||
          song.artist.toLowerCase().contains(query) ||
          song.album.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  List<LocalSong> get speedDialSongs =>
      _songs.take(9).toList(growable: false);

  List<LocalSong> get savedSongs => _songs
      .where((song) => _savedSongIds.contains(song.id))
      .toList(growable: false);

  Future<void> initialize() => refreshLibrary();

  Future<void> refreshLibrary() async {
    _isLoading = true;
    _permissionDenied = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final granted = await _libraryService.requestLibraryPermission();
      if (!granted) {
        _permissionDenied = true;
        return;
      }

      _songs = await _libraryService.loadSongs();
      _queueLoaded = false;
    } catch (error) {
      _errorMessage = 'Could not read local music: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> playSong(LocalSong song) async {
    final index = _songs.indexWhere((item) => item.id == song.id);
    if (index < 0) return;

    if (!_queueLoaded) {
      final items = _songs.map(_toMediaItem).toList(growable: false);
      await _audioHandler.loadQueueAndPlay(items, initialIndex: index);
      _queueLoaded = true;
    } else {
      await _audioHandler.skipToQueueItem(index);
      await _audioHandler.play();
    }
  }

  Future<void> togglePlayPause() async {
    if (_currentSong == null && _songs.isNotEmpty) {
      await playSong(_songs.first);
      return;
    }
    if (_isPlaying) {
      await _audioHandler.pause();
    } else {
      await _audioHandler.play();
    }
  }

  Future<void> seek(Duration value) => _audioHandler.seek(value);

  Future<void> next() => _audioHandler.skipToNext();

  Future<void> previous() => _audioHandler.skipToPrevious();

  Future<void> toggleShuffle() async {
    _shuffleEnabled = !_shuffleEnabled;
    await _audioHandler.setShuffleMode(
      _shuffleEnabled
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
    );
    notifyListeners();
  }

  Future<void> cycleRepeatMode() async {
    _repeatMode = switch (_repeatMode) {
      AudioServiceRepeatMode.none => AudioServiceRepeatMode.all,
      AudioServiceRepeatMode.all => AudioServiceRepeatMode.one,
      AudioServiceRepeatMode.group => AudioServiceRepeatMode.one,
      AudioServiceRepeatMode.one => AudioServiceRepeatMode.none,
    };
    await _audioHandler.setRepeatMode(_repeatMode);
    notifyListeners();
  }

  void updateSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void selectMood(String value) {
    _selectedMood = value;
    notifyListeners();
  }

  bool isLiked(int id) => _likedSongIds.contains(id);
  bool isDisliked(int id) => _dislikedSongIds.contains(id);
  bool isSaved(int id) => _savedSongIds.contains(id);

  void toggleLike(int id) {
    if (!_likedSongIds.add(id)) {
      _likedSongIds.remove(id);
    } else {
      _dislikedSongIds.remove(id);
    }
    notifyListeners();
  }

  void toggleDislike(int id) {
    if (!_dislikedSongIds.add(id)) {
      _dislikedSongIds.remove(id);
    } else {
      _likedSongIds.remove(id);
    }
    notifyListeners();
  }

  void toggleSave(int id) {
    if (!_savedSongIds.add(id)) {
      _savedSongIds.remove(id);
    }
    notifyListeners();
  }

  MediaItem _toMediaItem(LocalSong song) {
    return MediaItem(
      id: song.playableUri,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: song.duration,
      artUri: song.artworkUri,
      extras: {
        'localSongId': song.id,
      },
    );
  }

  void _handleMediaItem(MediaItem? item) {
    if (item == null) return;
    final id = item.extras?['localSongId'];
    if (id is! int) return;
    final index = _songs.indexWhere((song) => song.id == id);
    if (index < 0) return;
    _currentSong = _songs[index];
    notifyListeners();
  }

  void _handlePlaybackState(PlaybackState state) {
    _isPlaying = state.playing;
    _isBuffering = state.processingState == AudioProcessingState.loading ||
        state.processingState == AudioProcessingState.buffering;
    _shuffleEnabled = state.shuffleMode != AudioServiceShuffleMode.none;
    _repeatMode = state.repeatMode;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }
}
