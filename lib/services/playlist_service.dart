// lib/services/playlist_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/song_model.dart';

class PlaylistService {
  static const List<String> _audioExtensions = [
    '.mp3', '.m4a', '.aac', '.wav', '.flac', '.ogg', '.opus', '.wma',
  ];

  // Directories to scan for music on Android
  static const List<String> _scanPaths = [
    '/storage/emulated/0/Music',
    '/storage/emulated/0/Download',
    '/storage/emulated/0/Downloads',
    '/storage/emulated/0/DCIM',
    '/storage/emulated/0',
  ];

  // Get all songs from device by scanning directories
  Future<List<SongModel>> getAllSongs() async {
    final List<SongModel> songs = [];
    final Set<String> seenPaths = {};

    for (final path in _scanPaths) {
      final dir = Directory(path);
      if (await dir.exists()) {
        try {
          await _scanDirectory(dir, songs, seenPaths, recursive: path == '/storage/emulated/0/Music');
        } catch (_) {}
      }
    }

    // Also try external storage paths
    try {
      final externalDirs = await getExternalStorageDirectories();
      if (externalDirs != null) {
        for (final dir in externalDirs) {
          // Go up to the root of external storage
          final root = dir.parent.parent.parent.parent;
          if (await root.exists()) {
            await _scanDirectory(root, songs, seenPaths, recursive: true, maxDepth: 3);
          }
        }
      }
    } catch (_) {}

    // Sort by title
    songs.sort((a, b) => a.title.compareTo(b.title));
    return songs;
  }

  Future<void> _scanDirectory(
    Directory dir,
    List<SongModel> songs,
    Set<String> seenPaths, {
    bool recursive = false,
    int maxDepth = 5,
    int currentDepth = 0,
  }) async {
    if (currentDepth > maxDepth) return;

    try {
      final entities = await dir.list().toList();
      for (final entity in entities) {
        if (entity is File) {
          final ext = entity.path.toLowerCase();
          final isAudio = _audioExtensions.any((e) => ext.endsWith(e));
          if (isAudio && !seenPaths.contains(entity.path)) {
            seenPaths.add(entity.path);
            songs.add(_fileToSong(entity));
          }
        } else if (entity is Directory && recursive && currentDepth < maxDepth) {
          // Skip hidden directories
          final name = entity.path.split('/').last;
          if (!name.startsWith('.')) {
            await _scanDirectory(
              entity, songs, seenPaths,
              recursive: true,
              maxDepth: maxDepth,
              currentDepth: currentDepth + 1,
            );
          }
        }
      }
    } catch (_) {}
  }

  SongModel _fileToSong(File file) {
    final filename = file.path.split('/').last;
    // Remove extension
    final nameWithoutExt = filename.contains('.')
        ? filename.substring(0, filename.lastIndexOf('.'))
        : filename;

    // Try to parse "Artist - Title" format
    String title = nameWithoutExt;
    String artist = 'Unknown Artist';

    if (nameWithoutExt.contains(' - ')) {
      final parts = nameWithoutExt.split(' - ');
      artist = parts[0].trim();
      title = parts.sublist(1).join(' - ').trim();
    }

    return SongModel(
      id: file.path.hashCode.toString(),
      title: title,
      artist: artist,
      filePath: file.path,
    );
  }

  // Get songs by artist
  Future<List<SongModel>> getSongsByArtist(String artist) async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => song.artist == artist).toList();
  }

  // Get songs by album
  Future<List<SongModel>> getSongsByAlbum(String album) async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => song.album == album).toList();
  }

  // Search songs
  Future<List<SongModel>> searchSongs(String query) async {
    final allSongs = await getAllSongs();
    final lowerQuery = query.toLowerCase();
    return allSongs.where((song) {
      return song.title.toLowerCase().contains(lowerQuery) ||
          song.artist.toLowerCase().contains(lowerQuery) ||
          (song.album?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}
