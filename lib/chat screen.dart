import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_new_socket_server/full_image_screen.dart';
import 'package:flutter_new_socket_server/new_question_model.dart';
import 'package:flutter_new_socket_server/play_audio.dart';
import 'package:flutter_new_socket_server/question_value.dart';
import 'package:flutter_new_socket_server/radiobutton.dart';
import 'package:flutter_new_socket_server/video_thumbnail.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:dospace/dospace.dart' as dospace;
import 'package:mime/mime.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:http/http.dart' as http;
import 'package:flushbar/flushbar.dart';
import 'package:flutter_new_socket_server/radiolist.dart';
import 'package:flutter_new_socket_server/dropdown_list.dart';
import 'package:flutter_new_socket_server/globals.dart' as globals;
import 'package:flutter_new_socket_server/new_question_model.dart';


class ChatPage extends StatefulWidget {
  final _globalKey = GlobalKey<ScaffoldState>();
  final String userName;
  final String room;
  final SocketIO socketIO;
  ChatPage({Key key, @required this.userName, this.room, this.socketIO}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>{
  //for picker file
  dynamic _pickImageError;
  final ImagePicker _picker = ImagePicker();
  PickedFile _image;
  File selected;
  var imgBytes;

  //for chat messages display //for animation and grabbing text of user messages
  List<Message> messages;
  TextEditingController textController, ageController;
  ScrollController scrollController;

  //for connecting and sending files to digital ocean
  dospace.Spaces spaces = new dospace.Spaces(
      region: "nyc3",
      accessKey: "CELXQMHTONNB5C22MM4O",
      secretKey: "EQZpdf4XE1oRcOhsbPeivgCpuRcNlFSrDVvGTsyQLL0");

  // //for audio files
  PlayAudio playAudio;

  //for video files
  // VideoPlayerController _videoPlayerController;
  // ChewieController _chewieController;
  var videoFileName;
  var filePath;


  int selectedRadioTile;
  List<dynamic> dropdownQuestionOptions = List();
  String dropdownQuestionSummary = "";
  Flushbar<List<String>> flushBar;
  List<dynamic> options = List();
  NewQuestions ques = NewQuestions();



  @override
  void initState() {
    super.initState();
    //Initialising variables for chat
    messages = List<Message>();
    textController = new TextEditingController();
    scrollController = ScrollController();
    ageController = new TextEditingController();

    // new Future.delayed(Duration.zero, () async {
    //   await register();
    //   bottomSheet(widget._globalKey.currentState.context);
    // });

    // register();

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        print("visible: " + visible.toString());
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          curve: Curves.fastOutSlowIn,
          duration: const Duration(milliseconds: 300),
        );
      },
    );

    //for socket connection
    if(widget.socketIO==null){
      widget.socketIO.connect();
    }

    //for joining the chat room
    widget.socketIO.sendMessage(
        'join',
        json.encode({
          // 'userId': widget.userName,
          'roomId': widget.room
        }), _onReceiveChatMessage);

    //for listening to socket events on message received
    widget.socketIO.subscribe('message', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      print('subscribe data' + data.toString());
      print('intent: ' + data['intent'].toString());
      // data['questions'].entries.forEach((e) => questionsList.add(e.key, e.value));
      // print(list);

      this.setState(() {
        if(data['msg'] != null){
          if (data.containsKey('intent') && data['intent'] != null) {
            String intent = data['intent'];
            if(data['question_options'] != null) {
              options = data['question_options'];
            }
            showBottomSheet(intent);
            print('First bLock');
            messages.add(Message(message: data['msg'], sender: data['userType'], type: 'message'));
          } else if (data.containsKey('questions') && data['questions'] != null) {
            ques = questionsFromJson(jsonData);
            messages.add(Message(message: data['msg'], sender: data['userType'], type: 'message'));
            print('second block');
            bottomSheet();
            print(ques.msg);
          } else {
            messages.add(Message(message: data['msg'], sender: data['userType'], type: 'message'));
          }
        } else {
          // _createFileFromString(data['file']);
          print('file data: ' + data['file']['path']);
          String mimeType = data['file']['mimetype'];
          String fileType = mimeType.substring(0, mimeType.indexOf('/'));
          print(fileType);
          messages.add(Message(sender:data['userId'], message:data['file']['path'], type: fileType));
        }
      });
    });

  }

  showBottomSheet(String title) {
    globals.intent = title;
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return BottomSheet(
            backgroundColor: Colors.black87,
              onClosing: () {},
              builder: (context){
                return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Text(title.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),),
                        ),
                      ),
                      Divider(height: 5, color: Colors.grey,),
                      // options != null ? radioButtonsForBottomSheet() : textFieldForBottomSheet()
                      title == 'language' || title == 'gender' ? radioButtonsForBottomSheet() : textFieldForBottomSheet()
                    ],
                  );
              });
        });
  }

  Widget textFieldForBottomSheet(){
    String text = globals.intent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(5),
          child: Text('Please enter your $text', style: TextStyle(fontSize: 16.0, color: Colors.white),),
        ),
        SizedBox(height: 10,),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                padding: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width * 0.4,
                child: TextField(
                  controller: ageController,
                  textAlign: TextAlign.center,
                  decoration: new InputDecoration(
                    hintText: '1',
                    filled: true,
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                      borderSide: new BorderSide(
                        color: Colors.black,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)
              ),
              onPressed: () {
                onPressedAge();
              },
              color: Colors.redAccent,
              child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white,),
            ),

          ],
        )
      ],
    );
  }

  Widget radioButtonsForBottomSheet(){
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(options.length, (index){
        return RadioButtonList(txt: options[index], index: index, onPressed: onPressedLanguage);

      }),
    );
  }

  void _onReceiveChatMessage(dynamic message) {
    print("onReceive: " + message);
  }

  void uploadToDigitalOcean(File imageFile) async {
    String project_name = "shafa";
    String region = "nyc3";
    String folder_name = "chat_files";
    String file_name = imageFile.path.split('/').last;
    final mimeType = lookupMimeType(imageFile.path);
    // print('mimeType: ' + mimeType);
    String basename = p.basename(imageFile.path);

    String etag = await spaces.bucket(project_name).uploadFile(
        folder_name + '/' + file_name,
        imageFile,
        mimeType,
        dospace.Permissions.private);
    print('upload: $etag');

    String uploaded_file_url =
        "https://"+project_name+"."+region+".digitaloceanspaces.com/"
            + folder_name + "/" + file_name;
    print('uploaded_url: $uploaded_file_url');

    String fileUrlForSocket = folder_name + "/" + file_name;
    sendFile(basename, fileUrlForSocket, mimeType);

    // await spaces.close();
  }

  void sendFile (String fileName, String filePath, String mime) async {
    print('sendFile called');
    await widget.socketIO.sendMessage('sendMessage',
        json.encode({'file': {'filename': fileName, 'path': filePath, 'mimetype': mime}}));
  }

  Widget imgMessage(int index) {
    return GestureDetector(
      onTap: (){
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenImage(
                imgUrl: 'https://api-user.shafa.care/api/v1/auth/file/${messages[index].message}'
              ),
            ));
      },
      child: Image.network(
          'https://api-user.shafa.care/api/v1/auth/file/${messages[index].message}',
          height: 240,
          width: 180,
          fit: BoxFit.scaleDown,
        ),
    );
  }

  void buildAgeIntentMessage(String title) {
    flushBar = new Flushbar<List<String>>(
      titleText: Text(title.toUpperCase(),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),), //change later according to disease
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.GROUNDED,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticIn,
      messageText: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:[
          Text('Please Enter Age'),
          SizedBox(height: 10,),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                child: TextField(
                  controller: ageController,
                  textAlign: TextAlign.center,
                  decoration: new InputDecoration(
                    hintText: '1',
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                      borderSide: new BorderSide(
                        color: Colors.black,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 35,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  onPressed: () {
                    onPressedAge();
                  },
                  color: Colors.redAccent,
                  child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white,),
                ),
              ),
            ],
          )
        ]
        ),
    )..show(context);
  }
  onPressedAge(){
    String age = ageController.text;
    widget.socketIO.sendMessage('sendMessage',
        json.encode({'msg': age, 'intent': globals.intent}));
    setState(() {
      ageController.clear();
    });
    Navigator.pop(context);

  }
  void buildLanguageIntentMessage(String title, List<dynamic> options){
    globals.intent = title;
    flushBar = new Flushbar<List<String>>(
      titleText: Text(title.toUpperCase(),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),), //change later according to disease
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.GROUNDED,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticIn,
      messageText: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:
          List.generate(options.length, (index) {
            return RadioButtonList(txt: options[index], index: index, onPressed: onPressedLanguage,);
          }
          )
        ,
      ),
    )..show(context);
  }

  onPressedLanguage(){
    setState(() {
      options.clear();
    });
    widget.socketIO.sendMessage('sendMessage',
        json.encode({'msg': globals.selectedButton, 'intent': globals.intent}));
    // flushBar.dismiss();
    Navigator.pop(context);

  }



  Widget buildSingleMessage(int index) {
    var user = messages[index].sender;
    var currentUser = '1';
    print('user: ' + user.toString());
    return Row(
      mainAxisAlignment:  user == currentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: user == currentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        SizedBox(width: user == currentUser ? 30.0 : 20.0,),
        if (user != currentUser) ...[
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
                user == currentUser ? 'https://i.pravatar.cc/150?img=3' : 'https://i.pravatar.cc/150?img=4'
            ), radius: 20,
          ),
          const SizedBox(width: 5.0,)
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: user == currentUser ? Colors.red : Colors.white,
              borderRadius: BorderRadius.circular(10.0)
            ),
            child: Text(
              messages[index].message,
              style: TextStyle(color: user == currentUser ? Colors.white : Colors.black, fontSize: 18.0),
            ),
          ),
        ),
        if (user == currentUser) ...[
          const SizedBox(width: 5.0,),
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
                user == currentUser ? 'https://i.pravatar.cc/150?img=3' : 'https://i.pravatar.cc/150?img=4'
            ), radius: 10,
          ),
        ],
        SizedBox(width: user == currentUser ? 20.0 : 30.0,),
      ],
    );
  }

  Widget buildFileMessage(int index) {
    var user = messages[index].sender;
    var currentUser = 1;
    return Row(
      mainAxisAlignment:  user == currentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: user == currentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        SizedBox(width: user == currentUser ? 30.0 : 20.0,),
        if (user != currentUser) ...[
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
                user == currentUser ? 'https://i.pravatar.cc/150?img=3' : 'https://i.pravatar.cc/150?img=4'
            ), radius: 20,
          ),
          const SizedBox(width: 5.0,)
        ],
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: BoxDecoration(
              color: user == currentUser ? Colors.red : Colors.white,
              borderRadius: BorderRadius.circular(10.0)
          ),
          child: _generateMediaWidget(index),
        ),
        if (user == currentUser) ...[
          const SizedBox(width: 5.0,),
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
                user == currentUser ? 'https://i.pravatar.cc/150?img=3' : 'https://i.pravatar.cc/150?img=4'
            ), radius: 10,
          ),
        ],
        SizedBox(width: user == currentUser ? 20.0 : 30.0,),
      ],
    );
  }

   _generateMediaWidget(int index){
    if (messages[index].type == 'image'){
      return imgMessage(index);
    } else if (messages[index].type == 'audio') {
      // return audioMessage(index);
      return new PlayAudio(url: messages[index].message);
    } else if (messages[index].type == 'video'){
      return new VideoThumb(url: messages[index].message);
    }
  }

  Widget buildMessageList() {
    return ListView.separated(
        physics: BouncingScrollPhysics(),
        separatorBuilder: (context, index){
          return const SizedBox(height: 20,);
        },
        controller: scrollController,
        itemCount: messages.length,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index){
          return messages[index].type == 'message' ? buildSingleMessage(index) : buildFileMessage(index);
        },
      );
  }

  void _imgFromGallery() async {
    try {
      final PickedFile image = await  _picker.getImage(
          source: ImageSource.gallery, imageQuality: 50
      );

      setState(() {
        _image = image;
        selected = File(_image.path);
        // messages.add(Message(message: selected, sender: widget.userName, type: 'image'));
        // sendImage(selected);
        uploadToDigitalOcean(selected);
        print(image.path);
      });
    } catch (e) {
      setState((){
        _pickImageError = e;
      });
    }
  }

  void _anyFile(String fileType) async {
    FilePickerResult result;
    if(fileType == 'audio'){
      result = await FilePicker.platform.pickFiles(
          type: FileType.audio
        // allowedExtensions: ['mp3'],
      );
    } else if (fileType == 'video') {
      result = await FilePicker.platform.pickFiles(
          type: FileType.video
        // allowedExtensions: ['mp3'],
      );
    } else {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf']
      );
    }

    if(result != null) {
      PlatformFile file = result.files.first;

      print(file.name);
      print(file.bytes);
      print(file.size);
      print(file.extension);
      print(file.path);
      selected = File(file.path);
      uploadToDigitalOcean(selected);
    } else {
      // User canceled the picker
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {

                      Navigator.of(context).pop();
                    },
                  ),
                  new ListTile(
                    leading: new Icon(Icons.audiotrack),
                    title: new Text('Audio'),
                    onTap: () {
                      _anyFile('audio');
                      Navigator.of(context).pop();
                    },
                  ),
                  new ListTile(
                    leading: new Icon(Icons.ondemand_video_rounded),
                    title: new Text('Video'),
                    onTap: () {
                      _anyFile('video');
                      Navigator.of(context).pop();
                    },
                  ),
                  new ListTile(
                    leading: new Icon(Icons.insert_drive_file),
                    title: new Text('Document'),
                    onTap: () {
                      _anyFile('document');
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
  
  _sendTextMessage() {
    if (textController.text.isEmpty) return;
    FocusScope.of(context).requestFocus(FocusNode());
    widget.socketIO.sendMessage('sendMessage',
        json.encode({'msg': textController.text}));
    setState(() {
      textController.clear();
    });
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget buildInputArea(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30.0)
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              textInputAction: TextInputAction.send,
              controller: textController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                  hintText: "Send a message...."
              ),
              onEditingComplete: _sendTextMessage,
            ),
          ),
          IconButton(
            icon: Icon(Icons.attach_file),
            color: Colors.grey,
            onPressed: () {
              _showPicker(context);
              // print(questions.data.questions.length);
            },
          ),
          IconButton(
            icon: Icon(Icons.send),
            color: Colors.red,
            onPressed: _sendTextMessage,
          )
        ],
      ),
    );
  }

  // Future<QuestionClass> register() async {
  //   final String url =
  //       'http://30.30.253.172:3030/api/v1/auth/symptoms/get';
  //   final client = new http.Client();
  //   Map body = {'id': 3};
  //   final response = await client.post(
  //     url,
  //     headers: {
  //       HttpHeaders.contentTypeHeader: 'application/json',
  //       "Authorization": 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyQWNjZXNzIjoiMzM5LTc5MDAxNTEwLWY0MDctNDZlNi05Y2M4LTcwM2Q0MTljMDM4ZSIsImlhdCI6MTYxNDY4MzE3OCwiZXhwIjo4NjQwMDAwMDAxNjE0NjgzMDAwLCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjMwMzAifQ.HLnuPqb4kujlla6PlMm5MqGdX7kyYmG78DUd8eq1ZDc',
  //     },
  //     body: json.encode(body),
  //   );
  //   if (response.statusCode == 200 && response.body != null) {
  //     print(response.body);
  //     questions = questionClassFromJson(response.body);
  //     setState(() {
  //     });
  //
  //   } else {
  //     print(response.statusCode);
  //     print(response.body);
  //   }
  //   return questions;
  //
  // }

  Widget questionList(BuildContext c){
      return ListView.builder(
        itemCount: ques.questions.length,
        shrinkWrap: true,
        itemBuilder: (context, index){
          String key = ques.questions.keys.elementAt(index);
          print(key);
          dropdownQuestionOptions = ques.questions[key].question.questionOptions;
          dropdownQuestionSummary = ques.questions[key].question.summery;
          return questionWithOptions(c, key, index);
        },
      );

  }

  Widget questionWithOptions(BuildContext c, String key, int index){
    int i = index;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 16,),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(child: Text(ques.questions[key].question.question,
            style: TextStyle(color: Colors.white, fontSize: 16.0),)),
        ),
        SizedBox(height: 8,),
        generateRightWidget(c, key, i),
      ],
    );
  }
  generateRightWidget(BuildContext c, String key, int index){
    if (ques.questions[key].question.questionType == 0) {
      return new RadioListItem(ques: ques, index: key,);
    } else if (ques.questions[key].question.questionType ==1){
      return Text('checkbox');
    } else {
      return _getQuestionOptionsDropDown();
      // return List.generate(questions.data.questions[index].questionOptions.length, (ind) {
      //   return DropDown(questions: questions, questionIndex: index, i: ind,);
      // }
    }
  }
  _getQuestionOptionsDropDown(){
    return Container(
      height: 35,
      child: ListView.builder(
        itemCount: dropdownQuestionOptions.length,
        itemBuilder: (context, index) {
          return DropDown(questionOptions: dropdownQuestionOptions, questionIndex: index, summary: dropdownQuestionSummary,);
        },
      ),
    );
  }


  void bottomSheet() {
    flushBar = Flushbar<List<String>>(
      titleText: Text("Fever",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),), //change later according to disease
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.GROUNDED,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticIn,
      messageText: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          questionList(context),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: FractionallySizedBox(
                widthFactor: 0.18,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  onPressed: () {
                    flushBar.dismiss();

                    // globals.selectedRadioAnswer.forEach((key, value) {
                    //   summaryList.add(Summary(key, value));
                    // });
                    // globals.selectedRadioMap.forEach((key, value) {
                    //   quesNValuesList.add(QuesNValues(key, value));
                    // });

                    String msgText = globals.selectedSummaryAnswerMap.toString();
                    String msg = msgText.substring(1, msgText.length - 1);
                    var list = [];
                    list.add(globals.selectQuesValuesMap);

                    print(msg);
                    print(list);

                    widget.socketIO.sendMessage('sendMessage',
                        json.encode({'msg': msg, 'answer': list.toString()}));
                    // print(quesNValuesList.toString());
                    // print(summaryList.toString());

                  },
                  color: Colors.redAccent,
                  child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white,),
                ),
              ),
            ),
          )
        ],
      ),
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget._globalKey,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.userName),
      ),
      body: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
            Expanded(child: buildMessageList()),
            buildInputArea(context)
          ],
        ),
    );
  }
}

class Message {
  final dynamic message;
  final dynamic sender;
  final String type;

  Message({this.message, this.sender, this.type});
}


