import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../models/playlist_model.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../widgets/song_tile.dart';

class PlaylistScreen extends StatelessWidget {
  final List<SongModel> allSongs;

  const PlaylistScreen({super.key, required this.allSongs});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, playlistProvider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Playlists',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: Color(0xFF1DB954), size: 32),
                    onPressed: () => _showCreateDialog(context, playlistProvider),
                  ),
                ],
              ),
            ),
            Expanded(
              child: playlistProvider.playlists.isEmpty
                  ? _buildEmptyState(context, playlistProvider)
                  : ListView.builder(
                      itemCount: playlistProvider.playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = playlistProvider.playlists[index];
                        final songCount = playlist.songIds.length;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF282828),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.playlist_play,
                                color: Color(0xFF1DB954), size: 28),
                          ),
                          title: Text(
                            playlist.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            '$songCount ${songCount == 1 ? 'song' : 'songs'}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: PopupMenuButton(
                            icon: const Icon(Icons.more_vert,
                                color: Colors.grey),
                            color: const Color(0xFF282828),
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'rename',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('Rename',
                                        style:
                                            TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'rename') {
                                _showRenameDialog(
                                    context, playlistProvider, playlist);
                              } else if (value == 'delete') {
                                _showDeleteDialog(
                                    context, playlistProvider, playlist);
                              }
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlaylistDetailScreen(
                                  playlist: playlist,
                                  allSongs: allSongs,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(
      BuildContext context, PlaylistProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.queue_music, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No Playlists Yet',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 10),
          const Text(
            'Create a playlist to organize your music',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DB954),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => _showCreateDialog(context, provider),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Create Playlist',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(
      BuildContext context, PlaylistProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text('New Playlist',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Playlist name',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1DB954))),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1DB954))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.createPlaylist(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create',
                style: TextStyle(color: Color(0xFF1DB954))),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, PlaylistProvider provider,
      PlaylistModel playlist) {
    final controller = TextEditingController(text: playlist.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Rename Playlist',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Playlist name',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1DB954))),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1DB954))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.renamePlaylist(playlist.id, controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save',
                style: TextStyle(color: Color(0xFF1DB954))),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, PlaylistProvider provider,
      PlaylistModel playlist) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Delete Playlist',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${playlist.name}"?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              provider.deletePlaylist(playlist.id);
              Navigator.pop(ctx);
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Playlist Detail Screen
class PlaylistDetailScreen extends StatelessWidget {
  final PlaylistModel playlist;
  final List<SongModel> allSongs;

  const PlaylistDetailScreen({
    super.key,
    required this.playlist,
    required this.allSongs,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, playlistProvider, child) {
        final currentPlaylist =
            playlistProvider.playlists.firstWhere((p) => p.id == playlist.id,
                orElse: () => playlist);
        final songs =
            playlistProvider.getPlaylistSongs(currentPlaylist, allSongs);

        return Scaffold(
          backgroundColor: const Color(0xFF191414),
          appBar: AppBar(
            backgroundColor: const Color(0xFF191414),
            title: Text(currentPlaylist.name,
                style: const TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              if (songs.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    context.read<AudioProvider>().setPlaylist(songs, 0);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.play_arrow,
                      color: Color(0xFF1DB954)),
                  label: const Text('Play All',
                      style: TextStyle(color: Color(0xFF1DB954))),
                ),
            ],
          ),
          body: songs.isEmpty
              ? const Center(
                  child: Text('No songs in this playlist',
                      style: TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return Consumer<AudioProvider>(
                      builder: (ctx, audioProvider, _) {
                        return SongTile(
                          song: song,
                          isPlaying: audioProvider.currentSong?.id == song.id &&
                              audioProvider.isPlaying,
                          isSelected:
                              audioProvider.currentSong?.id == song.id,
                          onTap: () {
                            context
                                .read<AudioProvider>()
                                .setPlaylist(songs, index);
                          },
                          allSongs: allSongs,
                          showRemoveFromPlaylist: true,
                          onRemoveFromPlaylist: () {
                            playlistProvider.removeSongFromPlaylist(
                                currentPlaylist.id, song.id);
                          },
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}
