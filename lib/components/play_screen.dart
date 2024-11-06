import 'package:flutter/material.dart';
import 'package:flutter_music_app/models/music_model.dart';
import 'package:just_audio/just_audio.dart';

class PlaybarBottomSheet extends StatelessWidget {
  final List<Color> gradientColors;
  final AudioPlayer audioPlayer;
  final MusicData musicData;
  final bool isSliderDragging;
  final double? dragValue;
  final ValueChanged<double> onSliderChanged;
  final ValueChanged<double> onSliderChangeEnd;
  final ValueChanged<double> onSliderChangeStart;
  final Function() onTogglePlayPause;
  final Function(Duration) formatDuration;

  const PlaybarBottomSheet({
    super.key,
    required this.gradientColors,
    required this.audioPlayer,
    required this.musicData,
    required this.isSliderDragging,
    required this.dragValue,
    required this.onSliderChanged,
    required this.onSliderChangeEnd,
    required this.onSliderChangeStart,
    required this.onTogglePlayPause,
    required this.formatDuration,
  });

  Widget _buildAlbumCover(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        image: DecorationImage(
          image: NetworkImage(musicData.albumImageUrl),
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
                musicData.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                musicData.artist,
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
    return StreamBuilder<Duration>(
      stream: audioPlayer.positionStream,
      builder: (context, snapshot) {
        final duration = audioPlayer.duration ?? Duration.zero;
        final position = snapshot.data ?? Duration.zero;

        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 5,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                    pressedElevation: 0,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 0,
                  ),
                  thumbColor: Colors.white,
                  overlayColor: Colors.transparent,
                  trackShape: const RoundedRectSliderTrackShape(),
                ),
                child: Slider(
                  value: isSliderDragging
                      ? dragValue ?? position.inSeconds.toDouble()
                      : position.inSeconds.toDouble(),
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  onChangeStart: (value) {
                    onSliderChangeStart(value);
                    audioPlayer.pause();
                  },
                  onChanged: (value) {
                    onSliderChanged(value);
                    audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                  onChangeEnd: (value) {
                    onSliderChangeEnd(value);
                    audioPlayer.play();
                  },
                  activeColor: Colors.white,
                  inactiveColor: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatDuration(isSliderDragging
                        ? Duration(seconds: dragValue?.toInt() ?? 0)
                        : position),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    formatDuration(duration),
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
    return StreamBuilder<PlayerState>(
      stream: audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playing = snapshot.data?.playing ?? false;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous,
                  color: Colors.white, size: 36),
              onPressed: () {},
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(
                playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: Colors.white,
                size: 64,
              ),
              onPressed: onTogglePlayPause,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
              onPressed: () {},
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final albumCoverSize = MediaQuery.of(context).size.width - 64;

    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
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
