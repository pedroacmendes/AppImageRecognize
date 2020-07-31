// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Model _$ModelFromJson(Map<String, dynamic> json) {
  return Model(
    json['request_id'] as int,
    json['name'] as String,
    json['date'] == null ? null : DateTime.parse(json['date'] as String),
    json['file_tflite'] as String,
    json['file_txt'] as String,
  );
}

Map<String, dynamic> _$ModelToJson(Model instance) => <String, dynamic>{
      'request_id': instance.request_id,
      'name': instance.name,
      'date': instance.date?.toIso8601String(),
      'file_tflite': instance.file_tflite,
      'file_txt': instance.file_txt,
    };
