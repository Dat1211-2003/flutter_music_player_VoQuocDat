import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../services/audio_player_service.dart';
import '../widgets/progress_bar_widget.dart';
import '../widgets/player_controls.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      body: Consumer<AudioProvider>(
        builder: (context, provider, child) {
          final song = provider.currentSong;

          if (song == null) {
            return const Center(
              child:
                  Text('No song playing', style: TextStyle(color: Colors.white)),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, song),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),

                        // Album Art
                        _buildAlbumArt(song),

                        const SizedBox(height: 24),

                        // Song Info
                        _buildSongInfo(song),

                        const SizedBox(height: 16),

                        // Favorite & Options row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.favorite_border,
                                  color: Colors.grey),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.share, color: Colors.grey),
                              onPressed: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Progress Bar
                        StreamBuilder<CombinedPlaybackState>(
                          stream: provider.playbackStateStream,
                          builder: (context, snapshot) {
                            final state = snapshot.data;
                            return ProgressBarWidget(
                              position: state?.position ?? Duration.zero,
                              duration: state?.duration ?? Duration.zero,
                              onSeek: (position) {
                                provider.seek(position);
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Player Controls
                        PlayerControls(provider: provider),

                        const SizedBox(height: 20),

                        // Volume Control
                        _buildVolumeControl(provider),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, SongModel song) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down,
                color: Colors.white, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
          Column(
            children: [
              const Text(
                'Now Playing',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    letterSpacing: 1.5),
              ),
              if (song.album != null)
                Text(
                  song.album!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(SongModel song) {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1DB954).withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: song.albumArt != null
            ? Image.file(File(song.albumArt!), fit: BoxFit.cover)
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF282828), Color(0xFF404040)],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.music_note, size: 120, color: Color(0xFF1DB954)),
                ),
              ),
      ),
    );
  }

  Widget _buildSongInfo(SongModel song) {
    return Column(
      children: [
        Text(
          song.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          song.artist,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVolumeControl(AudioProvider provider) {
    return Row(
      children: [
        const Icon(Icons.volume_down, color: Colors.grey, size: 20),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.grey[800],
              thumbColor: Colors.white,
              overlayColor: Colors.white.withOpacity(0.2),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: provider.volume,
              min: 0.0,
              max: 1.0,
              onChanged: (value) {
                provider.setVolume(value);
              },
            ),
          ),
        ),
        const Icon(Icons.volume_up, color: Colors.grey, size: 20),
      ],
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282828),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading:
                    const Icon(Icons.playlist_add, color: Colors.white),
                title: const Text('Add to playlist',
                    style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.white),
                title: const Text('Share',
                    style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading:
                    const Icon(Icons.info_outline, color: Colors.white),
                title: const Text('Song info',
                    style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
