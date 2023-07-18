import 'dart:io';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:toast/toast.dart';

class FlickPlayer extends StatefulWidget {
  final File videoFile;
  const FlickPlayer({super.key, required this.videoFile});

  @override
  State<FlickPlayer> createState() => _FlickPlayerState();
}

class _FlickPlayerState extends State<FlickPlayer> {
  late VideoPlayerController _playerController;
  late FlickManager _manager;

  @override
  void initState() {
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    // ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _playerController = VideoPlayerController.file(widget.videoFile);
    _manager = FlickManager(videoPlayerController: _playerController);
    _manager.flickControlManager!.enterFullscreen();
    _playerController.setLooping(true);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _manager.dispose();
    _playerController.dispose();
    super.dispose();
  }

  Widget dropdownmenu(Size screen) {
    //I fucked upppp tsk
    return Container(
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
          border: Border.all(width: 1), color: Colors.amberAccent),
      height: 250,
      // width: screen.width,
      child: DropdownButton(
        onTap: () {
          print("Clicked");
        },
        isExpanded: true,
        isDense: true,
        icon: const Icon(
          Icons.one_x_mobiledata_rounded,
          size: 30,
          color: Colors.black,
        ),
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(
            value: 0.50,
            child: Text("0.50x"),
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
        itemHeight: kMinInteractiveDimension,
        onChanged: (value) {
          _playerController.setPlaybackSpeed(value!);
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      body: FlickVideoPlayer(
        flickVideoWithControls: FlickVideoWithControls(
          controls: dropdownmenu(screen),
          willVideoPlayerControllerChange: true,
          playerLoadingFallback: const CircularProgressIndicator(),
        ),
        flickManager: _manager,
        wakelockEnabled: true,
        wakelockEnabledFullscreen: true,
      ),
    );
  }
}
