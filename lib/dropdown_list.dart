import 'package:flutter/material.dart';
import 'package:flutter_new_socket_server/globals.dart' as globals;
import 'package:flutter_new_socket_server/question_value.dart';

class DropDown extends StatefulWidget {
  final List<dynamic> questionOptions;
  final int questionIndex;
  final String summary;

  DropDown({this.questionOptions, this.questionIndex, this.summary});


  @override
  _DropDownState createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  String _selectedItem;
  QuesNValues qV = QuesNValues();
  //
  // setSelectedRadioMap(dynamic id, dynamic val) {
  //   setState(() {
  //     globals.selectedRadioMap['$id'] = '$val';
  //   });
  // }

  // setSelectedSummaryAnswer(String summary, String value){
  //   setState(() {
  //     if (globals.selectedSummaryAnswer.isEmpty) {
  //       globals.selectedSummaryAnswer = '$summary: $value';
  //     } else {
  //       globals.selectedSummaryAnswer = globals.selectedSummaryAnswer + ', ' + '$summary: $value';
  //     }
  //   });
  // }

  setSelectedQuesAnsMap(Map m){
    setState(() {
      globals.selectQuesValuesMap[m['questionId']] = m['questionOptionId'];
    });
  }


  setSelectedSummaryAnswer(String summary, String value){
    setState(() {
      globals.selectedSummaryAnswerMap[summary] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 35.0,
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.red[500],
          ),
          borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_sharp),
          style: TextStyle(color: Colors.black87, fontSize: 14.0),
          elevation: 8,
          hint: Text('Select an option'),
          value: _selectedItem,
          onChanged: (val) {
            setState(() {
              _selectedItem = val;
              var m = QuesNValues(questionId: widget.questionOptions[widget.questionIndex].questionId, questionOptionId: val).toJson();
              setSelectedQuesAnsMap(m);
              // globals.selectedQuesValuesList.add(m);
              // print("questionid" + widget.questionOptions[widget.questionIndex].questionId.toString());
              // setSelectedRadioMap(widget.questionOptions[widget.questionIndex].questionId, val);
              // setSelectedQuesAnsMap(QuesNValues(questionId: widget.questionOptions[widget.questionIndex].questionId, questionOptionId: val));
              setSelectedSummaryAnswer(widget.summary, widget.questionOptions[widget.questionIndex].value);
              print(globals.selectQuesValuesMap);
            });
            print(_selectedItem);
          },
          items: (widget.questionOptions as List<dynamic>).map((e) {
            return DropdownMenuItem<String>(
              value: e.id.toString(),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(e.value.toString())),
            );
          }).toList(),
        ),
      ),
    );
  }
}


