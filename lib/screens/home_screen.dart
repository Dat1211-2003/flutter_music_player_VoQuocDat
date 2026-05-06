import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../services/playlist_service.dart';
import '../services/permission_service.dart';
import '../widgets/song_tile.dart';
import '../widgets/mini_player.dart';
import 'now_playing_screen.dart';
import 'playlist_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlaylistService _playlistService = PlaylistService();
  final PermissionService _permissionService = PermissionService();

  List<SongModel> _songs = [];
  bool _isLoading = true;
  bool _hasPermission = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _hasPermission = await _permissionService.requestStoragePermission();

    if (_hasPermission) {
      await _permissionService.requestAudioPermission();
      await _loadSongs();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSongs() async {
    try {
      final songs = await _playlistService.getAllSongs();
      if (mounted) {
        setState(() {
          _songs = songs;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading songs: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildBody(),
            ),
            Consumer<AudioProvider>(
              builder: (context, provider, child) {
                if (provider.currentSong == null) return const SizedBox.shrink();
                return MiniPlayer(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NowPlayingScreen()),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return SearchScreen(allSongs: _songs);
      case 2:
        return PlaylistScreen(allSongs: _songs);
      case 3:
        return const SettingsScreen();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1DB954)))
              : !_hasPermission
                  ? _buildPermissionDenied()
                  : _songs.isEmpty
                      ? _buildNoSongs()
                      : _buildSongList(),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Music',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_songs.length} songs',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadSongs,
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  setState(() => _selectedIndex = 1);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSongList() {
    return RefreshIndicator(
      onRefresh: _loadSongs,
      color: const Color(0xFF1DB954),
      child: ListView.builder(
        itemCount: _songs.length,
        itemBuilder: (context, index) {
          final song = _songs[index];
          return Consumer<AudioProvider>(
            builder: (context, provider, child) {
              final isCurrentSong = provider.currentSong?.id == song.id;
              return SongTile(
                song: song,
                isPlaying: isCurrentSong && provider.isPlaying,
                isSelected: isCurrentSong,
                onTap: () {
                  context.read<AudioProvider>().setPlaylist(_songs, index);
                },
                allSongs: _songs,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_off, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'Storage Permission Required',
              style: TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Please grant storage permission to access music files on your device.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () async {
                await openAppSettings();
              },
              child: const Text(
                'Open Settings',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSongs() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_note, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No Music Found',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 10),
          const Text(
            'Add some music files to your device',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DB954),
            ),
            onPressed: _loadSongs,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label:
                const Text('Refresh', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      backgroundColor: const Color(0xFF0D0D0D),
      selectedItemColor: const Color(0xFF1DB954),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(
            icon: Icon(Icons.playlist_play), label: 'Playlists'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
