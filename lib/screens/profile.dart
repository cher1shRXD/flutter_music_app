import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// YouTube 동영상을 재생하고 제어할 수 있는 프로필 화면 위젯
class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // YouTube 플레이어 컨트롤러
  late YoutubePlayerController _controller;
  // 동영상 ID 입력을 위한 컨트롤러
  late TextEditingController _idController;
  // 동영상 시간 이동을 위한 컨트롤러
  late TextEditingController _seekToController;

  // 현재 플레이어의 상태를 저장
  late PlayerState _playerState;
  // 현재 재생 중인 동영상의 메타데이터
  late YoutubeMetaData _videoMetaData;
  // 볼륨 레벨 (0-100)
  double _volume = 100;
  // 음소거 상태
  bool _muted = false;
  // 플레이어가 준비되었는지 확인하는 플래그
  bool _isPlayerReady = false;

  // 재생할 YouTube 동영상 ID 목록
  final List<String> _ids = [
    'Q0sZX07H2Ew',
    'gQDByCdjUXw',
    'iLnmTe5Q2Qw',
    '_WoCV4c6XOE',
    'KmzdUe0RSJo',
    '6jZDSSZZxjQ',
    'p2lYr3vM_1w',
    '7QUtEmBT_-w',
    '34_PXCzGw1M',
  ];

  @override
  void initState() {
    super.initState();
    // YouTube 플레이어 컨트롤러 초기화
    _controller = YoutubePlayerController(
      initialVideoId: _ids.first,
      flags: const YoutubePlayerFlags(
        mute: false, // 음소거 비활성화
        autoPlay: true, // 자동 재생 활성화
        disableDragSeek: false, // 드래그로 시간 이동 가능
        loop: false, // 반복 재생 비활성화
        isLive: false, // 실시간 스트리밍 비활성화
        forceHD: false, // HD 화질 강제 비활성화
        enableCaption: true, // 자막 활성화
      ),
    )..addListener(listener); // 상태 변화 감지를 위한 리스너 추가

    // 컨트롤러들 초기화
    _idController = TextEditingController();
    _seekToController = TextEditingController();
    _videoMetaData = const YoutubeMetaData();
    _playerState = PlayerState.unknown;
  }

  /// 플레이어 상태 변화를 감지하고 UI를 업데이트하는 리스너
  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    // 다른 페이지로 이동할 때 비디오 일시정지
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    // 위젯이 제거될 때 모든 컨트롤러 해제
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      // 전체화면 종료 시 기기 방향 설정 복원
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
        // 동영상 종료 시 다음 동영상 자동 재생
        onEnded: (data) {
          _controller
              .load(_ids[(_ids.indexOf(data.videoId) + 1) % _ids.length]);
          _showSnackBar('Next Video Started!');
        },
      ),
      builder: (context, player) => Scaffold(
        appBar: AppBar(
          leading: Padding(
              padding: const EdgeInsets.only(left: 12.0), child: Text('gd')),
          title: const Text(
            'Audio Player',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.video_library), onPressed: () => {}),
          ],
        ),
        body: Stack(
          children: [
            // 실제 플레이어는 화면 밖에 위치시킴 (오디오만 사용)
            Positioned(
              left: -1000,
              child: SizedBox(
                height: 1,
                width: 1,
                child: player,
              ),
            ),
            // 컨트롤 인터페이스
            ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _space,
                      // 동영상 제목 표시
                      _text('Title', _videoMetaData.title),
                      _space,
                      // 채널명 표시
                      _text('Channel', _videoMetaData.author),
                      _space,
                      // 재생 컨트롤 버튼들
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 이전 동영상 버튼
                          IconButton(
                            icon: const Icon(Icons.skip_previous),
                            onPressed: _isPlayerReady
                                ? () => _controller.load(_ids[(_ids.indexOf(
                                            _controller.metadata.videoId) -
                                        1) %
                                    _ids.length])
                                : null,
                          ),
                          // 재생/일시정지 버튼
                          IconButton(
                            icon: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                            onPressed: _isPlayerReady
                                ? () {
                                    _controller.value.isPlaying
                                        ? _controller.pause()
                                        : _controller.play();
                                    setState(() {});
                                  }
                                : null,
                          ),
                          // 음소거 버튼
                          IconButton(
                            icon: Icon(
                                _muted ? Icons.volume_off : Icons.volume_up),
                            onPressed: _isPlayerReady
                                ? () {
                                    _muted
                                        ? _controller.unMute()
                                        : _controller.mute();
                                    setState(() {
                                      _muted = !_muted;
                                    });
                                  }
                                : null,
                          ),
                          // 다음 동영상 버튼
                          IconButton(
                            icon: const Icon(Icons.skip_next),
                            onPressed: _isPlayerReady
                                ? () => _controller.load(_ids[(_ids.indexOf(
                                            _controller.metadata.videoId) +
                                        1) %
                                    _ids.length])
                                : null,
                          ),
                        ],
                      ),
                      _space,
                      // 볼륨 조절 슬라이더
                      Row(
                        children: <Widget>[
                          const Text(
                            "Volume",
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                          Expanded(
                            child: Slider(
                              inactiveColor: Colors.transparent,
                              value: _volume,
                              min: 0.0,
                              max: 100.0,
                              divisions: 10,
                              label: '${(_volume).round()}',
                              onChanged: _isPlayerReady
                                  ? (value) {
                                      setState(() {
                                        _volume = value;
                                      });
                                      _controller.setVolume(_volume.round());
                                    }
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      _space,
                      // 플레이어 상태 표시
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: _getStateColor(_playerState),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _playerState.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 제목과 값을 표시하는 텍스트 위젯 생성
  Widget _text(String title, String value) {
    return RichText(
      text: TextSpan(
        text: '$title : ',
        style: const TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  /// 플레이어 상태에 따른 색상 반환
  Color _getStateColor(PlayerState state) {
    switch (state) {
      case PlayerState.unknown:
        return Colors.grey[700]!;
      case PlayerState.unStarted:
        return Colors.pink;
      case PlayerState.ended:
        return Colors.red;
      case PlayerState.playing:
        return Colors.blueAccent;
      case PlayerState.paused:
        return Colors.orange;
      case PlayerState.buffering:
        return Colors.yellow;
      case PlayerState.cued:
        return Colors.blue[900]!;
      default:
        return Colors.blue;
    }
  }

  /// 위젯 간 간격을 위한 SizedBox
  Widget get _space => const SizedBox(height: 10);

  /// 동영상 로드/큐 버튼 생성
  Widget _loadCueButton(String action) {
    return Expanded(
      child: MaterialButton(
        color: Colors.blueAccent,
        onPressed: _isPlayerReady
            ? () {
                if (_idController.text.isNotEmpty) {
                  var id = YoutubePlayer.convertUrlToId(
                        _idController.text,
                      ) ??
                      '';
                  if (action == 'LOAD') _controller.load(id);
                  if (action == 'CUE') _controller.cue(id);
                  FocusScope.of(context).requestFocus(FocusNode());
                } else {
                  _showSnackBar('Source can\'t be empty!');
                }
              }
            : null,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Text(
            action,
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// 스낵바 표시 함수
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }
}
