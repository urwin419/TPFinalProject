// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DrinkingChart extends StatefulWidget {
  final List<Map<String, dynamic>> drinkingData;

  const DrinkingChart({super.key, required this.drinkingData});

  @override
  DrinkingChartState createState() => DrinkingChartState();
}

class DrinkingChartState extends State<DrinkingChart> {
  late List<Drink> _data;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().subtract(const Duration(days: 6));
    _endDate = DateTime.now();
    _generateData();
  }

  void _generateData() {
    _data = [];

    for (int i = 0; i < 7; i++) {
      final currentDate = _startDate.add(Duration(days: i));
      final dailyDrink = widget.drinkingData.firstWhere(
          (element) =>
              DateTime.parse(element['drinking_time']).toLocal().year ==
                  currentDate.year &&
              DateTime.parse(element['drinking_time']).toLocal().month ==
                  currentDate.month &&
              DateTime.parse(element['drinking_time']).toLocal().day ==
                  currentDate.day,
          orElse: () => {'drinking_time': '', 'drinking_volume': 0});

      _data.add(Drink(
          day: currentDate.day.toString(),
          volume: dailyDrink['drinking_volume']));
    }
  }

  void _updateDateRange(DateTime startDate) {
    setState(() {
      _startDate = startDate;
      _endDate = startDate.add(const Duration(days: 6));
      _generateData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(
            labelFormat: '{value} ml',
          ),
          series: <ChartSeries>[
            ColumnSeries<Drink, String>(
              dataSource: _data,
              xValueMapper: (Drink drink, _) => drink.day,
              yValueMapper: (Drink drink, _) => drink.volume,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _updateDateRange(
                  _startDate.subtract(const Duration(days: 7))),
              child: const Icon(Icons.chevron_left),
            ),
            ElevatedButton(
              onPressed: () =>
                  _updateDateRange(_startDate.add(const Duration(days: 7))),
              child: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }
}

class Drink {
  final String day;
  final int volume;

  Drink({required this.day, required this.volume});
}

class WeightChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const WeightChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          legend: const Legend(isVisible: true),
          series: <ChartSeries>[
            LineSeries<Map<String, dynamic>, String>(
              dataSource: data,
              xValueMapper: (Map<String, dynamic> data, _) =>
                  data['date'].toString(),
              yValueMapper: (Map<String, dynamic> data, _) => data['weight'],
              yAxisName: 'Weight (kg)',
              name: 'Weight',
              markerSettings: const MarkerSettings(isVisible: true),
            ),
            LineSeries<Map<String, dynamic>, String>(
              dataSource: data,
              xValueMapper: (Map<String, dynamic> data, _) =>
                  data['date'].toString(),
              yValueMapper: (Map<String, dynamic> data, _) => data['BMI'],
              yAxisName: 'BMI',
              name: 'BMI',
              markerSettings: const MarkerSettings(isVisible: true),
            ),
          ],
        ),
        const Text('Weight and BMI Chart'),
      ],
    );
  }
}

class MealTimeChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const MealTimeChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    List<MealTime> chartData = data.map((data) {
      DateTime date = DateTime.parse(data['meal_date']);
      num breakfast =
          DateTime.parse('1970-01-01 ${data['breakfast_time']}').hour;
      int? lunch = data['lunch_time'] != null
          ? DateTime.parse('1970-01-01 ${data['lunch_time']}').hour
          : null;
      int? dinner = data['dinner_time'] != null
          ? DateTime.parse('1970-01-01 ${data['dinner_time']}').hour
          : null;
      return MealTime(date, breakfast, lunch!, dinner!);
    }).toList();
    return Container(
        padding: const EdgeInsets.all(16.0),
        child: SfCartesianChart(
          primaryXAxis: DateTimeAxis(),
          primaryYAxis: NumericAxis(
            minimum: 0,
            maximum: 24,
            numberFormat: NumberFormat('00'),
          ),
          series: <LineSeries>[
            LineSeries<MealTime, DateTime>(
              dataSource: chartData,
              xValueMapper: (MealTime data, _) => data.date,
              yValueMapper: (MealTime data, _) => data.breakfast,
              name: 'Breakfast',
            ),
            LineSeries<MealTime, DateTime>(
              dataSource: chartData,
              xValueMapper: (MealTime data, _) => data.date,
              yValueMapper: (MealTime data, _) => data.lunch,
              name: 'Lunch',
            ),
            LineSeries<MealTime, DateTime>(
              dataSource: chartData,
              xValueMapper: (MealTime data, _) => data.date,
              yValueMapper: (MealTime data, _) => data.dinner,
              name: 'Dinner',
            ),
          ],
        ));
  }
}

class MealTime {
  final DateTime date;
  final num breakfast;
  final num lunch;
  final num dinner;

  MealTime(this.date, this.breakfast, this.lunch, this.dinner);
}

class ExerciseChart extends StatefulWidget {
  final List<Map<String, dynamic>> exerciseData;

  const ExerciseChart({super.key, required this.exerciseData});

  @override
  ExerciseChartState createState() => ExerciseChartState();
}

class ExerciseChartState extends State<ExerciseChart> {
  late List<ExerciseData> _chartData;

  @override
  void initState() {
    super.initState();
    _chartData = _getChartData();
  }

  List<ExerciseData> _getChartData() {
    List<ExerciseData> data = [];
    for (var exercise in widget.exerciseData) {
      DateTime exerciseTime = DateTime.parse(exercise['exercise_time']);

      DateTime firstDayOfWeek =
          exerciseTime.subtract(Duration(days: exerciseTime.weekday - 1));
      DateTime lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));

      if (exerciseTime.isAfter(firstDayOfWeek) &&
          exerciseTime.isBefore(lastDayOfWeek)) {
        ExerciseData? existingData;
        for (ExerciseData d in data) {
          if (d.week == firstDayOfWeek) {
            existingData = d;
            break;
          }
        }

        if (existingData != null) {
          existingData.exerciseAmount += exercise['exercise_amount'] as int;
        } else {
          data.add(ExerciseData(firstDayOfWeek, exercise['exercise_amount']));
        }
      }
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        title: AxisTitle(text: 'Week'),
        intervalType: DateTimeIntervalType.days,
        dateFormat: DateFormat('MM/dd'),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Exercise Amount'),
      ),
      series: <ChartSeries<ExerciseData, DateTime>>[
        ColumnSeries<ExerciseData, DateTime>(
          dataSource: _chartData,
          xValueMapper: (ExerciseData exercise, _) => exercise.week,
          yValueMapper: (ExerciseData exercise, _) => exercise.exerciseAmount,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }
}

class ExerciseData {
  DateTime week;
  int exerciseAmount;

  ExerciseData(this.week, this.exerciseAmount);
}

class BedTimeChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const BedTimeChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    List<BedTime> chartData = data.map((data) {
      DateTime date = DateTime.parse(data['sleep_date']);
      int? sleep = data['bed_time'] != null
          ? DateTime.parse('${data['bed_time']}').hour
          : DateTime.parse("${data['sleep_date']} 23:00:00").hour;
      int? wake = data['wake_up_time'] != null
          ? DateTime.parse('${data['wake_up_time']}').hour
          : DateTime.parse("${data['sleep_date']} 09:00:00").hour;

      return BedTime(date, sleep, wake);
    }).toList();
    return Container(
        padding: const EdgeInsets.all(16.0),
        child: SfCartesianChart(
          primaryXAxis: DateTimeAxis(),
          primaryYAxis: NumericAxis(
            minimum: 0,
            maximum: 24,
            numberFormat: NumberFormat('00'),
          ),
          series: <LineSeries>[
            LineSeries<BedTime, DateTime>(
              dataSource: chartData,
              xValueMapper: (BedTime data, _) => data.date,
              yValueMapper: (BedTime data, _) => data.sleep,
              name: 'Breakfast',
            ),
            LineSeries<BedTime, DateTime>(
              dataSource: chartData,
              xValueMapper: (BedTime data, _) => data.date,
              yValueMapper: (BedTime data, _) => data.wake,
              name: 'Lunch',
            ),
          ],
        ));
  }
}

class BedTime {
  final DateTime date;
  final num sleep;
  final num wake;

  BedTime(this.date, this.sleep, this.wake);
}
