import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WaterConsumption {
  final DateTime drinkingTime;
  final double drinkingVolume;

  WaterConsumption({
    required this.drinkingTime,
    required this.drinkingVolume,
  });
}

class WaterConsumptionChart extends StatefulWidget {
  const WaterConsumptionChart({super.key});

  @override
  WaterConsumptionChartState createState() => WaterConsumptionChartState();
}

class WaterConsumptionChartState extends State<WaterConsumptionChart> {
  int _currentWeekIndex = 0;
  List<List<WaterConsumption>> _weeklyData = [];

  @override
  void initState() {
    super.initState();
    List<Map<String, dynamic>> rawData = [
      {"drinking_time": "2023-07-17 20:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-17 17:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-17 14:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-17 10:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-16 20:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-16 17:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-16 14:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-16 10:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-15 20:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-15 17:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-15 14:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-15 10:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-14 20:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-14 17:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-14 14:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-14 10:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-13 20:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-13 17:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-13 14:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-13 10:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-12 20:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-12 17:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-12 14:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-12 10:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-11 20:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-11 17:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-11 14:00:00", "drinking_volume": 500},
      {"drinking_time": "2023-07-11 10:00:00", "drinking_volume": 500},
    ];

    _weeklyData = groupDataByWeek(rawData
        .map((data) => WaterConsumption(
            drinkingTime: DateTime.parse(data['drinking_time']),
            drinkingVolume: data['drinking_volume'].toDouble()))
        .toList());
  }

  List<List<WaterConsumption>> groupDataByWeek(List<WaterConsumption> rawData) {
    List<List<WaterConsumption>> weeklyData = [];
    List<WaterConsumption> currentWeekData = [];

    for (int i = 0; i < rawData.length; i++) {
      final currentData = rawData[i];
      final currentWeekday = currentData.drinkingTime.weekday;

      if (currentWeekday == DateTime.monday && currentWeekData.isNotEmpty) {
        weeklyData.add(currentWeekData);
        currentWeekData = [];
      }

      currentWeekData.add(currentData);
    }

    if (currentWeekData.isNotEmpty) {
      weeklyData.add(currentWeekData);
    }

    return weeklyData;
  }

  List<WaterConsumption> getCurrentWeekData() {
    if (_currentWeekIndex >= 0 && _currentWeekIndex < _weeklyData.length) {
      return _weeklyData[_currentWeekIndex];
    }

    return [];
  }

  void goToPreviousWeek() {
    setState(() {
      if (_currentWeekIndex > 0) {
        _currentWeekIndex--;
      }
    });
  }

  void goToNextWeek() {
    setState(() {
      if (_currentWeekIndex < _weeklyData.length - 1) {
        _currentWeekIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentWeekData = getCurrentWeekData();

    return Column(
      children: [
        SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          series: <ChartSeries>[
            ColumnSeries<WaterConsumption, String>(
              dataSource: currentWeekData,
              xValueMapper: (WaterConsumption data, _) =>
                  data.drinkingTime.weekday.toString(),
              yValueMapper: (WaterConsumption data, _) => data.drinkingVolume,
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: goToPreviousWeek,
              child: const Icon(Icons.arrow_left),
            ),
            ElevatedButton(
              onPressed: goToNextWeek,
              child: const Icon(Icons.arrow_right),
            ),
          ],
        ),
      ],
    );
  }
}
