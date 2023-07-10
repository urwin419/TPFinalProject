import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewAll extends StatelessWidget {
  const ViewAll({super.key, required this.type, required this.records});
  final String type;
  final List records;

  String _convertTime(inputDateStr) {
    DateFormat inputFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz');

    DateTime inputDate = inputFormat.parse(inputDateStr);

    DateFormat outputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    String outputDateStr = outputFormat.format(inputDate);

    return outputDateStr;
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
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: records.length,
          itemBuilder: (BuildContext context, int index) {
            switch (type) {
              case 'water':
                final record = records[index];
                final time = record['drinking_time'];
                final volume = record['drinking_volume'];
                final formattedTime = _convertTime(time);
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
                      title: Text('Drinking Time: $formattedTime'),
                      subtitle: Text('Drinking Volume: $volume ml'),
                    ));
              case 'body':
                final record = records[index];
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
                final record = records[index];
                final content = record['meal_content'];
                final date = record['meal_date'];
                final time = record['meal_time'];
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
                      title: Text('$content'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: $date'),
                          Text('Time: $time'),
                        ],
                      ),
                    ));
              case 'exercise':
                final record = records[index];
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
                final record = records[index];
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
