import 'package:flutter/material.dart';
import 'charts.dart';

class ViewAll extends StatefulWidget {
  const ViewAll({super.key, required this.type, required this.records});
  final String type;
  final List<Map<String, dynamic>> records;

  @override
  ViewAllState createState() => ViewAllState();
}

class ViewAllState extends State<ViewAll> {
  Widget _buildChildWidget() {
    if (widget.type == 'water') {
      return DrinkingChart(
        drinkingData: widget.records,
      );
    } else if (widget.type == 'body') {
      return WeightChart(data: widget.records);
    } else if (widget.type == 'meal') {
      return MealTimeChart(data: widget.records);
    } else if (widget.type == 'exercise') {
      return ExerciseChart(exerciseData: widget.records);
    } else {
      return BedTimeChart(data: widget.records);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'All Records',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('All Records'),
          backgroundColor: Colors.green,
        ),
        body: Column(children: [
          Expanded(
            child: _buildChildWidget(),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: widget.records.length,
              itemBuilder: (BuildContext context, int index) {
                switch (widget.type) {
                  case 'water':
                    final record = widget.records[index];
                    final time = record['drinking_time'];
                    final volume = record['drinking_volume'];
                    return Container(
                        width: 200.0,
                        height: 80.0,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage("assets/images/login.png"),
                            fit: BoxFit.cover,
                          ),
                          color: Colors.blue[300],
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text('Drinking Time: $time'),
                          subtitle: Text('Drinking Volume: $volume ml'),
                        ));
                  case 'body':
                    final record = widget.records[index];
                    final bmi = record['BMI'];
                    final date = record['date'];
                    final height = record['height'];
                    final weight = record['weight'];
                    return Container(
                        width: 200.0,
                        height: 80.0,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage("assets/images/login.png"),
                            fit: BoxFit.cover,
                          ),
                          color: Colors.blue[300],
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text('Date: $date'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('BMI: $bmi'),
                              Text('Height: $height'),
                              Text('Weight: $weight'),
                            ],
                          ),
                        ));
                  case 'meal':
                    final record = widget.records[index];
                    final date = record['meal_date'];
                    final breakfastTime = record['breakfast_time'];
                    final lunchTime = record['lunch_time'];
                    final dinnerTime = record['dinner_time'];
                    return Container(
                        width: 200.0,
                        height: 80.0,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage("assets/images/login.png"),
                            fit: BoxFit.cover,
                          ),
                          color: Colors.blue[300],
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text('$date'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Breakfast Time: $breakfastTime'),
                              Text('Lunch Time: $lunchTime'),
                              Text('Dinner Time: $dinnerTime'),
                            ],
                          ),
                        ));
                  case 'exercise':
                    final record = widget.records[index];
                    final amount = record['exercise_amount'];
                    final time = record['exercise_time'];
                    final type = record['exercise_type'];
                    return Container(
                        width: 200.0,
                        height: 80.0,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage("assets/images/login.png"),
                            fit: BoxFit.cover,
                          ),
                          color: Colors.blue[300],
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text('$type'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Amount: $amount'),
                              Text('Time: $time'),
                            ],
                          ),
                        ));
                  case 'sleep':
                    final record = widget.records[index];
                    final bedTime = record['bed_time'];
                    final sleepDate = record['sleep_date'];
                    final wakeUpTime = record['wake_up_time'];
                    return Container(
                        width: 200.0,
                        height: 80.0,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage("assets/images/login.png"),
                            fit: BoxFit.cover,
                          ),
                          color: Colors.blue[300],
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text('Sleep Date: $sleepDate'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bed Time: $bedTime'),
                              Text('Wake Up Time: $wakeUpTime'),
                            ],
                          ),
                        ));
                  default:
                    return null;
                }
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            ),
          )
        ]),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back),
        ),
      ),
    );
  }
}
