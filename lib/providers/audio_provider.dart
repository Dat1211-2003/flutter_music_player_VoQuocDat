import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayerService _audioService;
  final StorageService _storageService;

  List<SongModel> _playlist = [];
  int _currentIndex = 0;
  bool _isShuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;
  double _volume = 1.0;

  AudioProvider(this._audioService, this._storageService) {
    _init();
    _listenToPlayerCompletion();
  }

  // Getters
  List<SongModel> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  SongModel? get currentSong =>
      _playlist.isEmpty ? null : _playlist[_currentIndex];
  bool get isShuffleEnabled => _isShuffleEnabled;
  LoopMode get loopMode => _loopMode;
  double get volume => _volume;

  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;
  Stream<bool> get playingStream => _audioService.playingStream;
  Stream<CombinedPlaybackState> get playbackStateStream =>
      _audioService.playbackStateStream;

  bool get isPlaying => _audioService.isPlaying;

  // Initialize
  Future<void> _init() async {
    _isShuffleEnabled = await _storageService.getShuffleState();
    final repeatMode = await _storageService.getRepeatMode();
    _loopMode = LoopMode.values[repeatMode];
    await _audioService.setLoopMode(_loopMode);

    _volume = await _storageService.getVolume();
    await _audioService.setVolume(_volume);
    notifyListeners();
  }

  void _listenToPlayerCompletion() {
    _audioService.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_loopMode == LoopMode.off) {
          _handleSongCompletion();
        }
      }
    });
  }

  void _handleSongCompletion() {
    if (_playlist.isNotEmpty && _currentIndex < _playlist.length - 1) {
      next();
    }
  }

  // Set playlist
  Future<void> setPlaylist(List<SongModel> songs, int startIndex) async {
    _playlist = songs;
    _currentIndex = startIndex;
    await _playSongAtIndex(_currentIndex);
    notifyListeners();
  }

  // Play song at index
  Future<void> _playSongAtIndex(int index) async {
    if (index < 0 || index >= _playlist.length) return;

    _currentIndex = index;
    final song = _playlist[index];

    await _audioService.loadAudio(song.filePath);
    await _audioService.play();
    await _storageService.saveLastPlayed(song.id);

    notifyListeners();
  }

  // Play/Pause
  Future<void> playPause() async {
    if (_audioService.isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.play();
    }
    notifyListeners();
  }

  // Next song
  Future<void> next() async {
    if (_playlist.isEmpty) return;
    if (_isShuffleEnabled) {
      _currentIndex = _getRandomIndex();
    } else {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    }
    await _playSongAtIndex(_currentIndex);
  }

  // Previous song
  Future<void> previous() async {
    if (_playlist.isEmpty) return;
    if (_audioService.currentPosition.inSeconds > 3) {
      await _audioService.seek(Duration.zero);
    } else {
      if (_isShuffleEnabled) {
        _currentIndex = _getRandomIndex();
      } else {
        _currentIndex =
            (_currentIndex - 1 + _playlist.length) % _playlist.length;
      }
      await _playSongAtIndex(_currentIndex);
    }
  }

  // Seek
  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  // Toggle shuffle
  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;
    await _storageService.saveShuffleState(_isShuffleEnabled);
    notifyListeners();
  }

  // Toggle repeat
  Future<void> toggleRepeat() async {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        break;
    }

    await _audioService.setLoopMode(_loopMode);
    await _storageService.saveRepeatMode(_loopMode.index);
    notifyListeners();
  }

  // Set volume
  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _audioService.setVolume(volume);
    await _storageService.saveVolume(volume);
    notifyListeners();
  }

  // Get random index
  int _getRandomIndex() {
    if (_playlist.length <= 1) return 0;
    final random = Random();
    int newIndex;
    do {
      newIndex = random.nextInt(_playlist.length);
    } while (newIndex == _currentIndex);
    return newIndex;
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
