import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter_music_app/components/play_screen.dart';
import 'package:flutter_music_app/models/music_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

mixin PaletteGeneratorMixin on State<Playbar> {
  List<Color> gradientColors = [Colors.white, Colors.white];
  bool isLoading = true;

  Future<void> updatePaletteColors(String imageUrl) async {
    try {
      final ImageProvider imageProvider = NetworkImage(imageUrl);
      final generator = await PaletteGenerator.fromImageProvider(
        imageProvider,
      );

      if (!mounted) return;

      setState(() {
        Color dominantColor = generator.dominantColor?.color ?? Colors.white;
        Color darkenedDominant = HSLColor.fromColor(dominantColor)
            .withLightness((HSLColor.fromColor(dominantColor).lightness * 0.8)
                .clamp(0.0, 0.8))
            .toColor();

        Color secondColor = generator.paletteColors.length > 1
            ? generator.paletteColors[1].color
            : generator.dominantColor?.color ?? Colors.white;
        Color darkenedSecond = HSLColor.fromColor(secondColor)
            .withLightness((HSLColor.fromColor(secondColor).lightness * 0.8)
                .clamp(0.0, 0.8))
            .toColor();

        gradientColors = [darkenedDominant, darkenedSecond];
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error generating palette: $e');
      setState(() {
        gradientColors = [Colors.white, Colors.white];
        isLoading = false;
      });
    }
  }
}

class Playbar extends StatefulWidget {
  const Playbar({super.key});

  @override
  State<Playbar> createState() => _PlaybarState();
}

class _PlaybarState extends State<Playbar> with PaletteGeneratorMixin {
  late YoutubePlayerController _controller;
  late YoutubeMetaData _videoMetaData;
  bool _isPlayerReady = false;
  bool isSliderDragging = false;
  double? dragValue;
  String _currentAlbumUrl = '';

  final List<String> _ids = ['FFaFZsqbWr0', 'Q0sZX07H2Ew'];

  int _currentIndex = 0;
  late MusicData musicData;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: _ids.first,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);

    _videoMetaData = const YoutubeMetaData();

    // 초기 음악 데이터 설정
    _updateMusicData(_ids.first);
  }

  void _updateMusicData(String videoId) {
    String newAlbumUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';

    setState(() {
      musicData = MusicData(
          title: 'Loading...', // 로딩 중임을 표시
          artist: 'Loading...',
          albumImageUrl: newAlbumUrl,
          videoId: videoId);

      if (_currentAlbumUrl != newAlbumUrl) {
        _currentAlbumUrl = newAlbumUrl;
        updatePaletteColors(newAlbumUrl);
      }
    });
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _videoMetaData = _controller.metadata;

        // 메타데이터가 유효한 경우에만 업데이트
        if (_videoMetaData.title.isNotEmpty) {
          String newAlbumUrl =
              'https://img.youtube.com/vi/${_controller.metadata.videoId}/0.jpg';

          musicData = MusicData(
              title: _videoMetaData.title,
              artist: _videoMetaData.author,
              albumImageUrl: newAlbumUrl,
              videoId: _controller.metadata.videoId);

          if (_currentAlbumUrl != newAlbumUrl) {
            _currentAlbumUrl = newAlbumUrl;
            updatePaletteColors(newAlbumUrl);
          }
        }
      });
    }
  }

  void togglePlayPause() {
    HapticFeedback.lightImpact();
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  void playNextVideo() {
    HapticFeedback.lightImpact();
    if (_currentIndex < _ids.length - 1) {
      _currentIndex++;
      _updateMusicData(_ids[_currentIndex]); // 즉시 UI 업데이트
      _controller.load(_ids[_currentIndex]);
    }
  }

  void playPreviousVideo() {
    HapticFeedback.lightImpact();
    if (_currentIndex > 0) {
      _currentIndex--;
      _updateMusicData(_ids[_currentIndex]); // 즉시 UI 업데이트
      _controller.load(_ids[_currentIndex]);
    }
  }

  String _formatDuration(Duration duration) {
    String minutes = duration.inMinutes.toString().padLeft(2, '0');
    String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _handleSliderChangeEnd(double value) {
    _controller.seekTo(Duration(seconds: value.toInt()));
    setState(() {
      isSliderDragging = false;
      dragValue = null;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      builder: (context, player) => Stack(
        children: [
          Positioned(
            left: -1000,
            child: SizedBox(
              height: 1,
              width: 1,
              child: player,
            ),
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                isDismissible: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) => PlaybarBottomSheet(
                  gradientColors: gradientColors,
                  controller: _controller,
                  musicData: musicData,
                  onSliderChangeEnd: _handleSliderChangeEnd,
                  onTogglePlayPause: togglePlayPause,
                  onNextVideo: playNextVideo,
                  onPreviousVideo: playPreviousVideo,
                  formatDuration: _formatDuration,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 80),
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 5.0,
                    spreadRadius: 0.0,
                    offset: const Offset(0, 0),
                  ),
                ],
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      image: DecorationImage(
                        image: NetworkImage(musicData.albumImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          musicData.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          musicData.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.black87,
                    ),
                    onPressed: togglePlayPause,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: false,
        progressIndicatorColor: Colors.blueAccent,
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (data) {
          _controller
              .load(_ids[(_ids.indexOf(data.videoId) + 1) % _ids.length]);
        },
      ),
    );
  }
}
