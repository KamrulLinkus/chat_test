import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayVideoPage extends StatefulWidget {
  String url, fileName;

  PlayVideoPage({Key key, this.url, this.fileName}) : super(key: key);
  @override
  _PlayVideoPageState createState() => _PlayVideoPageState();
}

class _PlayVideoPageState extends State<PlayVideoPage> {
  //for video files
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;



  @override
  void initState() {
    super.initState();
    initializePlayer(widget.url);
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
    chewieController.dispose();
  }

  initializePlayer(String url) async {
    videoPlayerController = VideoPlayerController.network(
        url);
    await Future.wait([
      videoPlayerController.initialize().then((value) {
        setState(() {
        });
      }),
    ]);

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      aspectRatio: videoPlayerController.value.aspectRatio,
      autoPlay: true,
      looping: true,
      // Try playing around with some of these other options:

      // showControls: false,
      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.grey,
      //   bufferedColor: Colors.lightGreen,
      // ),
      // placeholder: Container(
      //   color: Colors.grey,
      // ),
      // autoInitialize: true,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
      ),
      body: Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: chewieController != null &&
                  chewieController
                      .videoPlayerController.value.initialized
                  ? Chewie(
                controller: chewieController,
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 5),
                  Text('Loading'),
                ],
              ),
            ),
          ),
    );
  }
}
