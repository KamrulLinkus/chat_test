import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_new_socket_server/play_video.dart';
import 'package:video_player/video_player.dart';

class VideoThumb extends StatefulWidget {
  final String url;

  const VideoThumb({Key key, this.url}) : super(key: key);

  @override
  _VideoThumbState createState() => _VideoThumbState();
}

class _VideoThumbState extends State<VideoThumb> {
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer(widget.url);

  }

  initializePlayer(String url) async {
    _videoPlayerController = new VideoPlayerController.network('https://api-user.shafa.care/api/v1/auth/file/${widget.url}');
    await Future.wait([
      _videoPlayerController.initialize().then((value) {
        setState(() {

        });
      }),
    ]);
    _chewieController = new ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 1/1,
      showControlsOnInitialize: true,
      showControls: false,
      autoPlay: false,
      looping: true,
    );
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
    _chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var lastsindex = widget.url.lastIndexOf('/');
    String name = widget.url.substring((lastsindex+1));

    return new Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: Colors.transparent,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2,

        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => new PlayVideoPage(
                    url: 'https://api-user.shafa.care/api/v1/auth/file/${widget.url}',
                    fileName: widget.url,
                  ),
                ));
          },
          child: new Column(
                children: [
                  _chewieController != null && _chewieController.videoPlayerController.value.initialized
                      ? new Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: new Chewie(controller: _chewieController),
                      ) : CircularProgressIndicator(),
                  SizedBox(height: 20.0),
                  Container(
                    color: Colors.grey,
                    child: new Text(name.trim(),
                      style: new TextStyle(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 12.0),
                    ),
                  )
                ],
              ),
        )
    );
  }
}
