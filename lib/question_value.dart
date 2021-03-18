import 'dart:convert';

QuesNValues quesNValuesFromJson(String str) => QuesNValues.fromJson(json.decode(str));

String quesNValuesToJson(QuesNValues data) => json.encode(data.toJson());

class QuesNValues {
  dynamic questionId;
  dynamic questionOptionId;

  QuesNValues({this.questionId, this.questionOptionId});

  QuesNValues.fromJson(Map<dynamic, dynamic> json) :
        questionId = json['questionId'],
        questionOptionId = json['questionOptionId'];

  Map<dynamic, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionOptionId': questionOptionId,
    };
  }

  @override
  String toString() {
    return '${this.questionId}: ${this.questionOptionId}';
  }
//
}
