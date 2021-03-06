import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlayAudio extends StatefulWidget {
  final String url;

  const PlayAudio({Key key, this.url}) : super(key: key);

  @override
  _PlayAudioState createState() => _PlayAudioState();
}

class _PlayAudioState extends State<PlayAudio> with TickerProviderStateMixin{
  //for audio files
  AnimationController _animationIconController1;
  AudioCache audioCache;
  AudioPlayer audioPlayer;
  Duration _duration = new Duration();
  Duration _position = new Duration();
  Duration _slider = new Duration(seconds: 0);
  double durationValue;
  bool isSongPlaying = false;
  bool isPlaying = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //for audio inside initState
    _position = _slider;
    _animationIconController1 = new AnimationController(
      vsync: this,
      duration: new Duration(milliseconds: 750),
      reverseDuration: new Duration(milliseconds: 750),
    );
    audioPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: audioPlayer);
    audioPlayer.durationHandler = (d) => setState(() {
      _duration = d;
    });

    audioPlayer.positionHandler = (p) => setState(() {
      _position = p;
    });

    print('audio widget: ' + widget.url);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    audioPlayer.dispose();
  }

  void seekToSeconds(int second) {
    Duration newDuration = Duration(seconds: second);
    audioPlayer.seek(newDuration);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isPlaying ? _animationIconController1.reverse() : _animationIconController1.forward();
                isPlaying = !isPlaying;
              });
              // Add code to pause and play the music.
              if (!isSongPlaying){
                audioPlayer.play('https://api-user.shafa.care/api/v1/auth/file/${widget.url}');
                setState(() {
                  isSongPlaying = true;
                });
              } else {
                audioPlayer.pause();
                setState(() {
                  isSongPlaying = false;
                });
              }
            },
            child: ClipOval(
              child: Container(
                color: Colors.pink[600],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AnimatedIcon(
                    icon: AnimatedIcons.play_pause,
                    size: 14,
                    progress: _animationIconController1,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Slider(
            activeColor: Colors.white,
            inactiveColor: Colors.grey,
            value: _position.inSeconds.toDouble(),
            max: _duration.inSeconds.toDouble(),
            onChanged: (double value) {
              seekToSeconds(value.toInt());
              value = value;
            },
          ),
        ],
      ),
    );
  }
}
