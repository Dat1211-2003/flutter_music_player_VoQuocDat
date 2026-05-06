import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../services/audio_player_service.dart';

class MiniPlayer extends StatelessWidget {
  final VoidCallback onTap;

  const MiniPlayer({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: Color(0xFF282828),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Consumer<AudioProvider>(
          builder: (context, provider, child) {
            final song = provider.currentSong;

            if (song == null) return const SizedBox.shrink();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress indicator
                StreamBuilder<CombinedPlaybackState>(
                  stream: provider.playbackStateStream,
                  builder: (context, snapshot) {
                    final progress = snapshot.data?.progress ?? 0.0;
                    return LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[800],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF1DB954)),
                      minHeight: 2,
                    );
                  },
                ),

                // Player content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        // Album art
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey[800],
                          ),
                          child: song.albumArt != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.file(
                                    File(song.albumArt!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.music_note,
                                  color: Color(0xFF1DB954), size: 24),
                        ),

                        const SizedBox(width: 12),

                        // Song info
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                song.artist,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Previous button
                        IconButton(
                          icon: const Icon(Icons.skip_previous,
                              color: Colors.white, size: 28),
                          onPressed: () => provider.previous(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),

                        const SizedBox(width: 8),

                        // Play/Pause button
                        StreamBuilder<bool>(
                          stream: provider.playingStream,
                          builder: (context, snapshot) {
                            final isPlaying = snapshot.data ?? false;
                            return GestureDetector(
                              onTap: () => provider.playPause(),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF1DB954),
                                ),
                                child: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(width: 8),

                        // Next button
                        IconButton(
                          icon: const Icon(Icons.skip_next,
                              color: Colors.white, size: 28),
                          onPressed: () => provider.next(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
