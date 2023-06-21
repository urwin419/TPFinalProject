// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exerecord.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExeRecord _$ExeRecordFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['date', 'time', 'type', 'content'],
  );
  return ExeRecord(
    json['date'] as String,
    json['time'] as String,
    json['type'] as String,
    json['content'] as String,
  );
}

Map<String, dynamic> _$ExeRecordToJson(ExeRecord instance) => <String, dynamic>{
      'date': instance.date,
      'time': instance.time,
      'type': instance.type,
      'content': instance.content,
    };
