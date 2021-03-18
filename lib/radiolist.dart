import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_new_socket_server/new_question_model.dart';
import 'package:flutter_new_socket_server/globals.dart' as globals;
import 'package:flutter_new_socket_server/question_value.dart';

class RadioListItem extends StatefulWidget {
  final String index;
  final NewQuestions ques;

  const RadioListItem({Key key, this.index, this.ques}) : super(key: key);
  @override
  _RadioListItemState createState() => _RadioListItemState();
}

class _RadioListItemState extends State<RadioListItem> {

  setSelectedRadioTile(int val) {
    setState(() {
      globals.selectedRadioTile = val;
    });
  }

  // setSelectedRadioMap(dynamic id, dynamic val) {
  //   setState(() {
  //     globals.selectedRadioMap['$id'] = '$val';
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

  // setSelectedSummaryAnswer(String summary, String value){
  //   setState(() {
  //     if (globals.selectedSummaryAnswer.isEmpty) {
  //       globals.selectedSummaryAnswer = '$summary: $value';
  //     } else {
  //       globals.selectedSummaryAnswer = globals.selectedSummaryAnswer + ', ' + '$summary: $value';
  //     }
  //   });
  // }

  setList(Map m) {
    setState(() {
      globals.selectedQuesValuesList.add(m);
      print(globals.selectedQuesValuesList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 0,
        crossAxisSpacing: 30,
        childAspectRatio: 2.0,
        mainAxisExtent: 50,
      ),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      children: new List.generate(
          widget.ques.questions[widget.index].question.questionOptions.length, (i) {
        return new Row(
          children: [
            Radio(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeColor: Colors.green,
              groupValue: globals.selectedRadioTile,
              value: widget.ques.questions[widget.index].question.questionOptions[i].id,
              onChanged: (val) {
                setSelectedRadioTile(val);
                var m = QuesNValues(questionId: widget.ques.questions[widget.index].question.questionOptions[i].questionId, questionOptionId: val).toJson();
                globals.selectedQuesValuesList.add(m);

                for (var item in globals.selectedQuesValuesList) {
                  if (item.containsKey('questionId')) {
                    print('QuestionID found');
                    if (item['questionId'] == widget.ques.questions[widget.index].question.questionOptions[i].questionId){
                       //globals.selectedQuesValuesList.remove(item);
                      print('removed');
                    } else {
                      print('else');
                    }
                  }
                  // globals.selectedQuesValuesList.add(m);
                }

                // setSelectedQuesAnsMap(m);
                setSelectedSummaryAnswer(widget.ques.questions[widget.index].question.summery, widget.ques.questions[widget.index].question.questionOptions[i].value);
                print(globals.selectedRadioTile);
                print(m);
                // setList(m);
                print(globals.selectedSummaryAnswer);

              },
            ),
            Expanded(child: Text(widget.ques.questions[widget.index].question.questionOptions[i].value,
            style: TextStyle(color: Colors.white, fontSize: 12),))
          ],
        );
      }),
    );
  }
}


// RadioListTile(
// value: widget.questions.data.questions[widget.index].questionOptions[i].id,
// title: new Text(
// widget.questions.data.questions[widget.index].questionOptions[i].value,
// style: TextStyle(fontSize: 10.0, color: Colors.white),),
// groupValue: selectedRadioTile,
// onChanged: (val) {
// setSelectedRadioTile(val);
// print(selectedRadioTile);
// },
// activeColor: Colors.green,
// );