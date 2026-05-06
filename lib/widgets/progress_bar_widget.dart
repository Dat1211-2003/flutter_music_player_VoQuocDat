import 'package:flutter/material.dart';
import '../utils/duration_formatter.dart';

class ProgressBarWidget extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final Function(Duration) onSeek;

  const ProgressBarWidget({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: const Color(0xFF1DB954),
            inactiveTrackColor: Colors.grey[800],
            thumbColor: Colors.white,
            overlayColor: const Color(0xFF1DB954).withOpacity(0.2),
          ),
          child: Slider(
            value: duration.inMilliseconds > 0
                ? position.inMilliseconds
                    .clamp(0, duration.inMilliseconds)
                    .toDouble()
                : 0.0,
            min: 0.0,
            max: duration.inMilliseconds > 0
                ? duration.inMilliseconds.toDouble()
                : 1.0,
            onChanged: (value) {
              onSeek(Duration(milliseconds: value.toInt()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DurationFormatter.format(position),
                style:
                    const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                DurationFormatter.format(duration),
                style:
                    const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
