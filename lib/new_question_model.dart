// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

NewQuestions questionsFromJson(String str) => NewQuestions.fromJson(json.decode(str));

String questionsToJson(NewQuestions data) => json.encode(data.toJson());

class NewQuestions {
  NewQuestions({
    this.roomId,
    this.userType,
    this.msg,
    this.intent,
    this.questions,
    this.questionOptions,
  });

  String roomId;
  int userType;
  String msg;
  dynamic intent;
  Map<String, QuestionValue> questions;
  dynamic questionOptions;

  factory NewQuestions.fromJson(Map<String, dynamic> json) => NewQuestions(
    roomId: json["roomId"],
    userType: json["userType"],
    msg: json["msg"],
    intent: json["intent"],
    questions: Map.from(json["questions"]).map((k, v) => MapEntry<String, QuestionValue>(k, QuestionValue.fromJson(v))),
    questionOptions: json["question_options"],
  );

  Map<String, dynamic> toJson() => {
    "roomId": roomId,
    "userType": userType,
    "msg": msg,
    "intent": intent,
    "questions": Map.from(questions).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
    "question_options": questionOptions,
  };
}

class QuestionValue {
  QuestionValue({
    this.id,
    this.questionId,
    this.commonSymptomId,
    this.order,
    this.question,
  });

  int id;
  int questionId;
  int commonSymptomId;
  dynamic order;
  QuestionQuestion question;

  factory QuestionValue.fromJson(Map<String, dynamic> json) => QuestionValue(
    id: json["id"],
    questionId: json["questionId"],
    commonSymptomId: json["commonSymptomId"],
    order: json["order"],
    question: QuestionQuestion.fromJson(json["question"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "questionId": questionId,
    "commonSymptomId": commonSymptomId,
    "order": order,
    "question": question.toJson(),
  };
}

class QuestionQuestion {
  QuestionQuestion({
    this.id,
    this.question,
    this.summery,
    this.questionType,
    this.questionOptions,
  });

  int id;
  String question;
  String summery;
  int questionType;
  List<QuestionOption> questionOptions;


  factory QuestionQuestion.fromJson(Map<String, dynamic> json) => QuestionQuestion(
    id: json["id"],
    question: json["question"],
    summery: json["summery"],
    questionType: json["questionType"],
    questionOptions: List<QuestionOption>.from(json["question_options"].map((x) => QuestionOption.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "question": question,
    "summery": summery,
    "questionType": questionType,
    "question_options": List<dynamic>.from(questionOptions.map((x) => x.toJson())),
  };
}

class QuestionOption {
  QuestionOption({
    this.id,
    this.value,
    this.questionId,
  });

  int id;
  String value;
  int questionId;

  factory QuestionOption.fromJson(Map<String, dynamic> json) => QuestionOption(
    id: json["id"],
    value: json["value"],
    questionId: json["questionId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "value": value,
    "questionId": questionId,
  };
}
