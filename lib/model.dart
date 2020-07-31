import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
class Model {
  int request_id;
  String name;
  DateTime date;
  String file_tflite;
  String file_txt;

  Model(this.request_id, this.name, this.date, this.file_tflite, this.file_txt);

  factory Model.fromJson(Map<String, dynamic> json) => _$ModelFromJson(json);

  Map<String, dynamic> toJson() => _$ModelToJson(this);
}
