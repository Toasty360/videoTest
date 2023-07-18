import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';

class MyPlayer extends StatefulWidget {
  final File? videoFile;
  final bool isM3u8;

  const MyPlayer({super.key, this.videoFile, required this.isM3u8});

  @override
  State<MyPlayer> createState() => _MyPlayerState();
}

class _MyPlayerState extends State<MyPlayer> {
  final MeeduPlayerController _controller = MeeduPlayerController(
    screenManager: const ScreenManager(
      hideSystemOverlay: true,
      forceLandScapeInFullscreen: true,
      systemUiMode: SystemUiMode.immersiveSticky,
      orientations: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    ),
    loadingWidget: const CircularProgressIndicator(),
    enabledButtons: const EnabledButtons(
      videoFit: false,
      playBackSpeed: false,
      pip: true,
      rewindAndfastForward: true,
    ),
    customIcons: const CustomIcons(
        minimize: Icon(
          Icons.fullscreen_exit,
          color: Colors.white,
        ),
        fullscreen: Icon(Icons.fullscreen_rounded, color: Colors.white),
        sound: Icon(Icons.volume_up_outlined, color: Colors.white),
        mute: Icon(Icons.volume_off_outlined, color: Colors.white)),
    manageWakeLock: true,
    showLogs: false,
    enabledControls: const EnabledControls(
        brightnessSwipes: true,
        doubleTapToSeek: true,
        volumeSwipes: true,
        escapeKeyCloseFullScreen: true,
        desktopDoubleTapToFullScreen: true,
        enterKeyOpensFullScreen: true,
        seekSwipes: true),
    excludeFocus: true,
    autoHideControls: true,
  );

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MeeduVideoPlayer(
          bottomRight: (context, controller, responsive) {
            return DropdownButton(
              alignment: AlignmentDirectional.center,
              icon: const Icon(
                Icons.one_x_mobiledata_rounded,
                color: Colors.white,
              ),
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: 0.50,
                  child: Text("0.50x"),
                ),
                DropdownMenuItem(
                  value: 1.0,
                  child: Text("1x"),
                ),
                DropdownMenuItem(
                  value: 1.5,
                  child: Text("1.5x"),
                ),
                DropdownMenuItem(
                  value: 2.0,
                  child: Text("2x"),
                ),
                DropdownMenuItem(
                  value: 2.5,
                  child: Text("2.5x"),
                ),
              ],
              onChanged: (value) {
                _controller.setPlaybackSpeed(value!);
              },
            );
          },
          controller: _controller
            ..header = AppBar(
              titleTextStyle: const TextStyle(color: Colors.white),
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
              ),
              title: const Text("Test video"),
            )
            ..setDataSource(
                DataSource(type: DataSourceType.file, file: widget.videoFile),
                autoplay: true,
                looping: true)),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller.dispose();
    super.dispose();
  }
}
