import 'dart:convert';

SummaryNAns sumNAnsFromJson(String str) => SummaryNAns.fromJson(json.decode(str));

String sumNAnsToJson(SummaryNAns data) => json.encode(data.toJson());

class SummaryNAns{
  final dynamic key;
  final dynamic msg;

  SummaryNAns(this.key, this.msg);

  SummaryNAns.fromJson(Map<dynamic, dynamic> json) :
        key = json['key'],
        msg = json['msg'];

  Map<dynamic, dynamic> toJson() {
    return {
      'key': key,
      'msg': msg,
    };
  }

  @override
  String toString() {
    return '${this.key}: ${this.msg}';
  }
}