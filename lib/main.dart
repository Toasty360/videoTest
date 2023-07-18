import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:testingapp/FlickPlayer.dart';
import 'package:toast/toast.dart';

import 'MyPlayer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initMeeduPlayer(logLevel: MPVLogLevel.error);

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'M3U8 to MP4 Downloader',
    theme: ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.blue,
    ),
    home: MyHomePage(),
  ));
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String m3u8Url =
      'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8';

  final TextEditingController _controller = TextEditingController();

  static List<File> data = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // convertM3U8toMP4();
    getFilesInDirectory("/storage/emulated/0/Download/m3u8/");
  }

  @override
  Widget build(BuildContext context) {
    // const ScreenManager(orientations: [DeviceOrientation.portraitUp]);
    return Scaffold(
      appBar: AppBar(
        title: const Text('M3U8 to MP4 Downloader'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
            child: ListView(
          children: [
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: TextField(
                  controller: _controller,
                  onSubmitted: (value) {
                    convertM3U8toMP4(m3u8Url: value);
                  },
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: "m3u8 url"),
                )),
            TextButton(
                onPressed: () {
                  setState(() {
                    if (_controller.text != "") {
                      convertM3U8toMP4(m3u8Url: _controller.text);
                    } else {
                      convertM3U8toMP4();
                    }
                  });
                },
                child: const Text("Download")),
            data.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return MyPlayer(
                                  isM3u8: false,
                                  videoFile: data[index],
                                );
                              },
                            ));
                            // Navigator.push(context, MaterialPageRoute(
                            //   builder: (context) {
                            //     return FlickPlayer(
                            //       videoFile: data[index],
                            //     );
                            //   },
                            // ));
                          },
                          child: Center(
                              child: Text(
                            data[index].path.split("/").last,
                            style: TextStyle(color: Colors.white),
                          )),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text("No Data"),
                  ),
          ],
        )),
      ),
    );
  }

  Future<void> getFilesInDirectory(String directoryPath) async {
    setState(() {
      Directory directory = Directory(directoryPath);
      List<File> files = [];

      if (directory.existsSync()) {
        files = directory.listSync().whereType<File>().toList();
      }

      data = files;
    });
  }

  Future<void> convertM3U8toMP4(
      {String m3u8Url =
          "https://assets.afcdn.com/video49/20210722/m3u8/lld/v_645516.m3u8"}) async {
    final FlutterFFmpeg flutterFFmpeg = FlutterFFmpeg();
    final FlutterFFmpegConfig fmpegConfig = FlutterFFmpegConfig();
    File file = File("/storage/emulated/0/Download/m3u8/videoTest.mp4");
    try {
      file.exists().then((value) {
        if (value) {
          file.delete();
        }
      });
    } catch (e) {
      print(e);
    }
    int totalDuration = 0;
    bool gotDuration = false;
    fmpegConfig.enableLogCallback((log) {
      String _log = log.message;
      // print("Log message: $_log");
      if (gotDuration && totalDuration != 0) {
        print("duration ig $_log");
        final List<String> timeParts = _log.split(':');
        final int hours = int.parse(timeParts[0]);
        final int minutes = int.parse(timeParts[1]);
        final int seconds = double.parse(timeParts[2]).toInt();

        totalDuration = hours * 3600 + minutes * 60 + seconds;
        print("got it $totalDuration");
      }
      gotDuration = _log.contains("Duration:");

      if (_log.contains("ZEN-TOTAL-DURATION")) {
        final RegExp regExp = RegExp(r'ZEN-TOTAL-DURATION:(\d+.\d+)');
        final Match? match = regExp.firstMatch(_log);
        if (match != null) {
          totalDuration = int.parse(match.group(1)!.split(".")[0]);
        }
      }
      if (_log.contains('time=')) {
        final RegExp regExp = RegExp(r'time=(\d+:\d+:\d+)');
        final Match? match = regExp.firstMatch(_log);

        if (match != null) {
          final String time = match.group(1)!;
          final List<String> timeParts = time.split(':');
          final int hours = int.parse(timeParts[0]);
          final int minutes = int.parse(timeParts[1]);
          final int seconds = int.parse(timeParts[2]);

          final int totalSeconds = hours * 3600 + minutes * 60 + seconds;
          final int progress = ((totalSeconds / totalDuration) * 100).round();
          Toast.show("$progress", duration: 1);
          print('Conversion Progress: $progress%');
        }
      }
    });
    await flutterFFmpeg
        .execute(
            '-i $m3u8Url -bsf:a aac_adtstoasc -vcodec copy -c copy ${file.path}')
        .then((value) {
      try {
        if (value != 0) {
          Toast.show("failed!");
        } else {
          Toast.show("Files updated!");
        }
      } catch (e) {
        print(e);
      }
    });
  }
}

Future<List> loadVideoFiles(String directoryPath) async {
  List<File> videos = (await getApplicationDocumentsDirectory())
      .listSync()
      .whereType<File>()
      .toList();

  print(videos.length);
  List vidList = [];
  // for (var video in videos) {
  //   final thumbnail = await generateThumbnail(video);
  //   vidList.add({File: video, "thumbnail": thumbnail});
  // }
  print(vidList.length);
  return vidList;
}
