// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weightrecord.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightRecord _$WeightRecordFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['date', 'weight'],
  );
  return WeightRecord(
    json['date'] as String,
    json['weight'] as String,
  );
}

Map<String, dynamic> _$WeightRecordToJson(WeightRecord instance) =>
    <String, dynamic>{
      'date': instance.date,
      'weight': instance.weight,
    };
