import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

class FullScreenImage extends StatelessWidget {
  final String imgUrl;

  const FullScreenImage({Key key, this.imgUrl}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(imgUrl),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        margin: EdgeInsets.all(20.0),
        child: PinchZoom(
          image: Image.network(imgUrl),
          zoomedBackgroundColor: Colors.black.withOpacity(0.5),
          resetDuration: const Duration(milliseconds: 100),
          maxScale: 2.5,
        )
      ),
    );
  }
}
