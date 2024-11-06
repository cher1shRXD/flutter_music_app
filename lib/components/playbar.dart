import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter_music_app/components/play_screen.dart';
import 'package:flutter_music_app/models/music_model.dart';

mixin AudioPlayerController on State<Playbar> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isSliderDragging = false;
  double? dragValue;

  Future<void> initAudioPlayer(String audioUrl) async {
    try {
      await audioPlayer.setUrl(audioUrl);
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
    }
  }

  void togglePlayPause() {
    if (audioPlayer.playing) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
  }

  @override
  void dispose() {
    audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
  }
}

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

class _PlaybarState extends State<Playbar>
    with AudioPlayerController, PaletteGeneratorMixin {
  late final MusicData musicData;

  @override
  void initState() {
    super.initState();
    musicData = const MusicData(
      title: '곡 제목',
      artist: '아티스트',
      albumImageUrl:
          'https://image.bugsm.co.kr/album/images/500/202444/20244482.jpg',
      audioUrl:
          'https://files.freemusicarchive.org//storage-freemusicarchive-org//tracks//CAsMyXsiK0RkmsBG2K75J4wdewYDJElKJCe1tSQM.mp3',
    );
    initAudioPlayer(musicData.audioUrl);
    updatePaletteColors(musicData.albumImageUrl);
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    String minutes = duration.inMinutes.toString().padLeft(2, '0');
    String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _handleSliderChanged(double value) {
    setState(() {
      dragValue = value;
    });
  }

  void _handleSliderChangeEnd(double value) {
    audioPlayer.seek(Duration(seconds: value.toInt()));
    setState(() {
      isSliderDragging = false;
      dragValue = null;
    });
  }

  void _handleSliderChangeStart(double value) {
    setState(() {
      isSliderDragging = true;
      dragValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: true,
          builder: (BuildContext context) => PlaybarBottomSheet(
            gradientColors: gradientColors,
            audioPlayer: audioPlayer,
            musicData: musicData,
            isSliderDragging: isSliderDragging,
            dragValue: dragValue,
            onSliderChanged: _handleSliderChanged,
            onSliderChangeEnd: _handleSliderChangeEnd,
            onSliderChangeStart: _handleSliderChangeStart,
            onTogglePlayPause: togglePlayPause,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    musicData.artist,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<PlayerState>(
              stream: audioPlayer.playerStateStream,
              builder: (context, snapshot) {
                final playing = snapshot.data?.playing ?? false;
                return IconButton(
                  icon: Icon(
                    playing ? Icons.pause : Icons.play_arrow,
                    color: Colors.black87,
                  ),
                  onPressed: togglePlayPause,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
