import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_new_socket_server/push_notification_service.dart';

import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:overlay_support/overlay_support.dart';
import 'chat screen.dart';




void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
          title: 'Flutter Demo',
          home: Home()
      ),
    );
  }
}

class Home extends StatefulWidget {
  final _globalKey = GlobalKey<ScaffoldState>(); // use this key for context issues
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool connected = false;
  SocketIO socketIO;
  TextEditingController nameController = new TextEditingController();
  TextEditingController roomController = new TextEditingController();
  String name, room;
  PushNotificationService _pushNotificationService = new PushNotificationService();
  BuildContext context;


  @override
  void initState() {
    super.initState();
    _connectToSocket();
    _pushNotificationService.initialise(context);

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    socketIO.destroy();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget._globalKey,
      appBar: AppBar(title: Text('Socket.io'),),
      body:  Column(
        children: [
          TextField(
            controller: nameController,

          ),
          TextField(
            controller: roomController,
          ),
          RaisedButton(onPressed: () {
            connectToSocket(context);
            // bottomSheet(context);
          },
            child: Text('GO CHAT'),
          ),

        ],
      ),
    );
  }



  void connectToSocket(BuildContext context) {
    if (nameController.text.isNotEmpty && roomController.text.isNotEmpty && socketIO!=null) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              userName: nameController.text,
              room: roomController.text,
              socketIO: socketIO,
            ),
          ));

    } else {
      print("please enter valid room and name");
    }


  }

  _connectToSocket(){
    var tok = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyQWNjZXNzIjoiMjYwLWI5MDNjN2I3LThmYmUtNDc3Yi04OTEzLTJkYmRiNmQ3YWFmMiIsImlhdCI6MTYxMzYyNjU1MSwiZXhwIjo4NjQwMDAwMDAxNjEzNjI2MDAwLCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjMwMzAifQ.zlY5IQUZ0Hb91xmCCRuHJ-md4RO37-1bbmQCn_Oi_R4';
    var query = 'token=$tok&userType=1';
    print("query: " + query.toString());
    socketIO = SocketIOManager().createSocketIO('https://test.shafa.care', '/', query: query,socketStatusCallback: _socketStatus);
    socketIO.init();
    socketIO.connect();
  }

  _socketStatus(dynamic data) {
    print("Socket status: " + data);
  }
  void _onReceiveChatMessage(dynamic message) {
    print("onReceive: " + message);
  }


}



