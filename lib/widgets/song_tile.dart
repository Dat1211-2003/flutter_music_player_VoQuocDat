import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/playlist_provider.dart';
import '../utils/duration_formatter.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final bool isPlaying;
  final bool isSelected;
  final List<SongModel> allSongs;
  final bool showRemoveFromPlaylist;
  final VoidCallback? onRemoveFromPlaylist;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    required this.allSongs,
    this.isPlaying = false,
    this.isSelected = false,
    this.showRemoveFromPlaylist = false,
    this.onRemoveFromPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          _buildAlbumArt(),
          if (isSelected)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.black54,
              ),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: const Color(0xFF1DB954),
                size: 28,
              ),
            ),
        ],
      ),
      title: Text(
        song.title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF1DB954) : Colors.white,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${song.artist}${song.duration != null ? ' • ${DurationFormatter.format(song.duration!)}' : ''}',
        style: const TextStyle(color: Colors.grey, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        onPressed: () {
          _showOptionsMenu(context);
        },
      ),
      onTap: onTap,
    );
  }

  Widget _buildAlbumArt() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: const Color(0xFF282828),
      ),
      child: song.albumArt != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(File(song.albumArt!), fit: BoxFit.cover),
            )
          : Icon(
              Icons.music_note,
              color: isSelected
                  ? const Color(0xFF1DB954)
                  : Colors.grey,
            ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    final playlistProvider = context.read<PlaylistProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282828),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Song info header
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF383838),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.music_note,
                          color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            song.artist,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey, height: 1),
              // Add to playlist
              ListTile(
                leading: const Icon(Icons.playlist_add,
                    color: Colors.white),
                title: const Text('Add to playlist',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddToPlaylistDialog(context, playlistProvider);
                },
              ),
              if (showRemoveFromPlaylist && onRemoveFromPlaylist != null)
                ListTile(
                  leading:
                      const Icon(Icons.remove_circle_outline,
                          color: Colors.red),
                  title: const Text('Remove from playlist',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    onRemoveFromPlaylist!();
                    Navigator.pop(ctx);
                  },
                ),
              ListTile(
                leading:
                    const Icon(Icons.info_outline, color: Colors.white),
                title: const Text('Song info',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSongInfo(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddToPlaylistDialog(
      BuildContext context, PlaylistProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Add to Playlist',
            style: TextStyle(color: Colors.white)),
        content: provider.playlists.isEmpty
            ? const Text(
                'No playlists. Create one first.',
                style: TextStyle(color: Colors.grey),
              )
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.playlists.length,
                  itemBuilder: (_, index) {
                    final playlist = provider.playlists[index];
                    return ListTile(
                      title: Text(playlist.name,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                          '${playlist.songIds.length} songs',
                          style: const TextStyle(color: Colors.grey)),
                      onTap: () {
                        provider.addSongToPlaylist(playlist.id, song);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Added to ${playlist.name}'),
                            backgroundColor:
                                const Color(0xFF1DB954),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Close', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showSongInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title:
            const Text('Song Info', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Title', song.title),
            _infoRow('Artist', song.artist),
            _infoRow('Album', song.album ?? 'Unknown'),
            if (song.duration != null)
              _infoRow('Duration', DurationFormatter.format(song.duration!)),
            if (song.fileSize != null)
              _infoRow('Size', '${(song.fileSize! / 1024 / 1024).toStringAsFixed(1)} MB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close',
                style: TextStyle(color: Color(0xFF1DB954))),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
