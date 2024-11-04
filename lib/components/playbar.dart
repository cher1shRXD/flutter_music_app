import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';

class Playbar extends StatefulWidget {
  const Playbar({super.key});

  @override
  State<Playbar> createState() => _PlaybarState();
}

class _PlaybarState extends State<Playbar> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Color> gradientColors = [Colors.white, Colors.white];
  final String albumImageUrl = 'https://i.redd.it/f78qbns6rrqb1.png';
  final String audioUrl =
      'https://files.freemusicarchive.org//storage-freemusicarchive-org//tracks//CAsMyXsiK0RkmsBG2K75J4wdewYDJElKJCe1tSQM.mp3';
  bool isLoading = true;
  bool isPlaying = false;
  Duration? duration;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _updatePaletteColors();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.setUrl(audioUrl);
      if (!mounted) return;

      // duration을 비동기로 기다린 후 설정
      final audioDuration = _audioPlayer.duration;
      if (!mounted) return;

      setState(() {
        duration = audioDuration;
      });

      // 재생 상태 리스너
      _audioPlayer.playerStateStream.listen((state) {
        if (!mounted) return;
        setState(() {
          isPlaying = state.playing;
        });
      });

      // 재생 위치 리스너
      _audioPlayer.positionStream.listen((pos) {
        if (!mounted) return;
        setState(() {
          position = pos;
        });
      });

      // duration 변경 리스너 추가
      _audioPlayer.durationStream.listen((updatedDuration) {
        if (!mounted) return;
        setState(() {
          duration = updatedDuration;
        });
      });
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    String minutes = duration.inMinutes.toString().padLeft(2, '0');
    String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _updatePaletteColors() async {
    final ImageProvider imageProvider = NetworkImage(albumImageUrl);
    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      imageProvider,
      size: const Size(800, 800),
    );

    if (!mounted) return;

    setState(() {
      Color dominantColor = generator.dominantColor?.color ?? Colors.white;
      Color darkenedDominant = HSLColor.fromColor(dominantColor)
          .withLightness((HSLColor.fromColor(dominantColor).lightness * 0.8)
              .clamp(0.8, 1.0))
          .toColor();

      Color secondColor = generator.paletteColors.length > 1
          ? generator.paletteColors[1].color
          : generator.dominantColor?.color ?? Colors.white;
      Color darkenedSecond = HSLColor.fromColor(secondColor)
          .withLightness(
              (HSLColor.fromColor(secondColor).lightness * 0.8).clamp(0.8, 1.0))
          .toColor();

      gradientColors = [darkenedDominant, darkenedSecond];
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final albumCoverSize = MediaQuery.of(context).size.width - 64;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: true,
          builder: (BuildContext context) {
            return Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
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
                      Container(
                        width: albumCoverSize,
                        height: albumCoverSize,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)),
                          image: DecorationImage(
                            image: NetworkImage(albumImageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '곡 제목',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '아티스트',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // 프로그레스 바
                      Slider(
                        value: position.inSeconds.toDouble(),
                        min: 0,
                        max: duration?.inSeconds.toDouble() ?? 0,
                        onChanged: (value) async {
                          await _audioPlayer
                              .seek(Duration(seconds: value.toInt()));
                        },
                        activeColor: Colors.white,
                        inactiveColor: Colors.white.withOpacity(0.3),
                      ),
                      // 시간 표시
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 재생 컨트롤
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous,
                                color: Colors.white, size: 36),
                            onPressed: () {
                              // 이전 곡 재생 로직
                            },
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              color: Colors.white,
                              size: 64,
                            ),
                            onPressed: () {
                              if (isPlaying) {
                                _audioPlayer.pause();
                              } else {
                                _audioPlayer.play();
                              }
                            },
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.skip_next,
                                color: Colors.white, size: 36),
                            onPressed: () {
                              // 다음 곡 재생 로직
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
                  image: NetworkImage(albumImageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '곡 제목',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '아티스트',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.black87,
              ),
              onPressed: () {
                if (isPlaying) {
                  _audioPlayer.pause();
                } else {
                  _audioPlayer.play();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
