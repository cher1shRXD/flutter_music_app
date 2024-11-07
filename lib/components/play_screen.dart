import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_music_app/models/music_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PlaybarBottomSheet extends StatefulWidget {
  final List<Color> gradientColors;
  final YoutubePlayerController controller;
  final MusicData musicData;
  final ValueChanged<double> onSliderChangeEnd;
  final Function() onTogglePlayPause;
  final Function() onNextVideo;
  final Function() onPreviousVideo;
  final Function(Duration) formatDuration;

  const PlaybarBottomSheet({
    super.key,
    required this.gradientColors,
    required this.controller,
    required this.musicData,
    required this.onSliderChangeEnd,
    required this.onTogglePlayPause,
    required this.onNextVideo,
    required this.onPreviousVideo,
    required this.formatDuration,
  });

  @override
  State<PlaybarBottomSheet> createState() => _PlaybarBottomSheetState();
}

class _PlaybarBottomSheetState extends State<PlaybarBottomSheet> {
  bool _isDragging = false;
  double? _currentSliderValue;

  Widget _buildAlbumCover(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        image: DecorationImage(
          image: NetworkImage(widget.musicData.albumImageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildAlbumInfo() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.musicData.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.musicData.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSlider() {
    return ValueListenableBuilder<YoutubePlayerValue>(
      valueListenable: widget.controller,
      builder: (context, value, child) {
        final position = value.position;
        final duration = value.metaData.duration;

        if (!_isDragging) {
          _currentSliderValue = position.inSeconds.toDouble();
        }

        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 5,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                    pressedElevation: 8,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 16,
                  ),
                  overlayColor: Colors.white.withOpacity(0.3),
                  thumbColor: Colors.white,
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white.withOpacity(0.3),
                  trackShape: const RoundedRectSliderTrackShape(),
                ),
                child: Slider(
                  value: (_currentSliderValue ?? 0)
                      .clamp(0, duration.inSeconds.toDouble()),
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  onChangeStart: (value) {
                    setState(() {
                      _isDragging = true;
                      _currentSliderValue = value;
                    });
                    HapticFeedback.lightImpact();
                  },
                  onChanged: (value) {
                    setState(() {
                      _currentSliderValue = value;
                    });
                  },
                  onChangeEnd: (value) {
                    setState(() {
                      _isDragging = false;
                    });
                    widget.onSliderChangeEnd(value);
                    HapticFeedback.mediumImpact();
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.formatDuration(
                      Duration(seconds: _currentSliderValue?.toInt() ?? 0),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    widget.formatDuration(duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlayControls() {
    return ValueListenableBuilder<YoutubePlayerValue>(
      valueListenable: widget.controller,
      builder: (context, value, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.loop,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {},
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous,
                  color: Colors.white, size: 32),
              onPressed: widget.onPreviousVideo,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            IconButton(
              icon: Icon(
                value.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_fill,
                color: Colors.white,
                size: 64,
              ),
              onPressed: widget.onTogglePlayPause,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white, size: 32),
              onPressed: widget.onNextVideo,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            IconButton(
              icon: const Icon(
                Icons.shuffle,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {},
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final albumCoverSize = MediaQuery.of(context).size.width - 48;

    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.gradientColors,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAlbumCover(albumCoverSize),
              const SizedBox(height: 24),
              _buildAlbumInfo(),
              const SizedBox(height: 12),
              _buildProgressSlider(),
              _buildPlayControls(),
            ],
          ),
        ),
      ),
    );
  }
}
