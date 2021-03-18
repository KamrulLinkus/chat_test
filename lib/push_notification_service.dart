import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';


class PushNotificationService{
  final FirebaseMessaging _fcm = FirebaseMessaging();


  Future initialise(BuildContext context) async {
    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }
    Future.delayed(Duration(seconds: 1), () {
      _fcm.configure(
        onMessage: (Map <String, dynamic> message) async {
          print('onMessage: $message');
          showOverlayNotification((context) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: SafeArea(
                child: ListTile(
                  leading: SizedBox.fromSize(
                      size: const Size(40, 40),
                      child: ClipOval(
                          child: Container(
                            color: Colors.black,
                          ))),
                  title: Text(message['notification']['title']),
                  subtitle: Text(message['notification']['body']),
                  trailing: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        OverlaySupportEntry.of(context).dismiss();
                      }),
                ),
              ),
            );
          }, duration: Duration(milliseconds: 4000));

          print(message['notification']['title']);
        },
        onLaunch: (Map <String, dynamic> message) async {
          print('onLaunchMessage: $message');
        },
        onResume: (Map <String, dynamic> message) async {
          print('onResumeMessage: $message');
        },

      );
    });

    _fcm.getToken().then((token) {
      print('firebaseToken: $token');
    }).catchError((e) {
      print(e);
    });

  }
}
