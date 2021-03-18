// import 'dart:convert';
//
// import 'package:flushbar/flushbar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_new_socket_server/radiobutton.dart';
// import 'package:flutter_new_socket_server/globals.dart' as globals;
// import 'package:flutter_socket_io/flutter_socket_io.dart';
//
// class CommonQuestionBar {
//   Flushbar<List<String>> flushBar;
//   final String title;
//   List<String> options;
//   final BuildContext context;
//   final SocketIO socketIO;
//   TextEditingController ageController = new TextEditingController();
//
//   CommonQuestionBar(this.title, this.context, this.socketIO);
//   CommonQuestionBar.fromCommonQuestionBar(this.title, this.options, this.context, this.socketIO);
//
//
//
//   void buildFlushBar(){
//     globals.intent = title;
//     flushBar = new Flushbar<List<String>>(
//       titleText: Text(title.toUpperCase(),
//         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),), //change later according to disease
//       flushbarPosition: FlushbarPosition.BOTTOM,
//       flushbarStyle: FlushbarStyle.GROUNDED,
//       reverseAnimationCurve: Curves.decelerate,
//       forwardAnimationCurve: Curves.elasticIn,
//       messageText: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: options != null ? buttonList() : [
//           otherWidget()
//         ]
//       ),
//     )..show(context);
//   }
//
//   onPressedLanguage(){
//     socketIO.sendMessage('sendMessage',
//         json.encode({'msg': globals.selectedButton, 'intent': globals.intent}));
//     flushBar.dismiss();
//   }
//
//   buttonList(){
//     List.generate(options.length, (index) {
//       return RadioButtonList(txt: options[index], index: index, onPressed: onPressedLanguage,);
//     });
//   }
//
//   Widget otherWidget(){
//     return Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children:[
//           Text('Please Enter Age'),
//           SizedBox(height: 10,),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SizedBox(
//                 width: 40,
//                 child: TextField(
//                   controller: ageController,
//                   textAlign: TextAlign.center,
//                   decoration: new InputDecoration(
//                     hintText: '1',
//                     border: new OutlineInputBorder(
//                       borderRadius: const BorderRadius.all(
//                         const Radius.circular(10.0),
//                       ),
//                       borderSide: new BorderSide(
//                         color: Colors.black,
//                         width: 1.0,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 width: 35,
//                 child: RaisedButton(
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0)
//                   ),
//                   onPressed: () {
//                     // onPressedAge();
//                   },
//                   color: Colors.redAccent,
//                   child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white,),
//                 ),
//               ),
//             ],
//           )
//         ]
//     );
//   }
//
// }