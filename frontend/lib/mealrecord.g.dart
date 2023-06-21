// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mealrecord.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealRecord _$MealRecordFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['date', 'time', 'meal'],
  );
  return MealRecord(
    json['date'] as String,
    json['time'] as String,
    json['meal'] as String,
  );
}

Map<String, dynamic> _$MealRecordToJson(MealRecord instance) =>
    <String, dynamic>{
      'date': instance.date,
      'time': instance.time,
      'meal': instance.meal,
    };
