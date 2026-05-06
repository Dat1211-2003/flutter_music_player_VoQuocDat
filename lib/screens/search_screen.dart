import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../widgets/song_tile.dart';

class SearchScreen extends StatefulWidget {
  final List<SongModel> allSongs;

  const SearchScreen({super.key, required this.allSongs});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SongModel> _filteredSongs = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _filteredSongs = widget.allSongs;
  }

  void _onSearch(String query) {
    setState(() {
      _query = query;
      if (query.isEmpty) {
        _filteredSongs = widget.allSongs;
      } else {
        final lower = query.toLowerCase();
        _filteredSongs = widget.allSongs.where((song) {
          return song.title.toLowerCase().contains(lower) ||
              song.artist.toLowerCase().contains(lower) ||
              (song.album?.toLowerCase().contains(lower) ?? false);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearch,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search songs, artists, albums...',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _onSearch('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF282828),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                _query.isEmpty
                    ? 'All Songs (${_filteredSongs.length})'
                    : 'Results for "$_query" (${_filteredSongs.length})',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredSongs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off,
                          size: 60, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _query.isEmpty
                            ? 'No songs found'
                            : 'No results for "$_query"',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredSongs.length,
                  itemBuilder: (context, index) {
                    final song = _filteredSongs[index];
                    return Consumer<AudioProvider>(
                      builder: (context, provider, child) {
                        final isCurrentSong =
                            provider.currentSong?.id == song.id;
                        return SongTile(
                          song: song,
                          isPlaying: isCurrentSong && provider.isPlaying,
                          isSelected: isCurrentSong,
                          onTap: () {
                            context
                                .read<AudioProvider>()
                                .setPlaylist(_filteredSongs, index);
                          },
                          allSongs: widget.allSongs,
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
