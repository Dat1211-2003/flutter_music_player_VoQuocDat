import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              _buildSection('Playback'),
              Consumer<AudioProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.shuffle, color: Colors.white),
                        title: const Text('Shuffle',
                            style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          provider.isShuffleEnabled ? 'Enabled' : 'Disabled',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: Switch(
                          value: provider.isShuffleEnabled,
                          onChanged: (_) => provider.toggleShuffle(),
                          activeColor: const Color(0xFF1DB954),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.volume_up, color: Colors.white),
                        title: const Text('Volume',
                            style: TextStyle(color: Colors.white)),
                        subtitle: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            activeTrackColor: const Color(0xFF1DB954),
                            inactiveTrackColor: Colors.grey[800],
                            thumbColor: const Color(0xFF1DB954),
                          ),
                          child: Slider(
                            value: provider.volume,
                            min: 0.0,
                            max: 1.0,
                            onChanged: (value) => provider.setVolume(value),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              _buildSection('About'),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.white),
                title: const Text('Version',
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text('1.0.0',
                    style: TextStyle(color: Colors.grey)),
              ),
              ListTile(
                leading: const Icon(Icons.music_note, color: Colors.white),
                title: const Text('Offline Music Player',
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text('Built with Flutter & just_audio',
                    style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF1DB954),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
