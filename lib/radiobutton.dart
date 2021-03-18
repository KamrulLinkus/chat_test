import 'package:flutter/material.dart';
import 'package:flutter_new_socket_server/globals.dart' as globals;

class RadioButtonList extends StatefulWidget {
  final String txt;
  final int index;
  final Function() onPressed;

  const RadioButtonList({Key key, this.txt, this.index, this.onPressed}) : super(key: key);
  @override
  _RadioButtonListState createState() => _RadioButtonListState();
}

class _RadioButtonListState extends State<RadioButtonList> {
  int sIndex;
  bool pressed = false;
  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      onPressed: () {changeIndex(widget.index);
      widget.onPressed();},
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      borderSide: new BorderSide(color: pressed && sIndex == widget.index? Colors.cyan : Colors.white),
      child:Text(widget.txt,style: TextStyle(color: pressed && sIndex == widget.index ?Colors.cyan : Colors.white),),
    );
  }

  void changeIndex(int index){
    setState(() {
      pressed = !pressed;
      sIndex = index;
      globals.selectedButton = widget.txt;
      print(widget.txt);
    });
  }
}
