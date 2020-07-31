import 'package:json_annotation/json_annotation.dart';

part 'recognizableobject.g.dart';

@JsonSerializable()
class RecognizableObject {
  String label;
  String description;

  RecognizableObject(this.label, this.description);

  factory RecognizableObject.fromJson(Map<String, dynamic> json) =>
      _$RecognizableObjectFromJson(json);

  Map<String, dynamic> toJson() => _$RecognizableObjectToJson(this);
}
