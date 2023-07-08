// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'main.dart';
import 'dart:ui' as ui;

class WaterTrackerWidget extends StatefulWidget {
  const WaterTrackerWidget({super.key});

  @override
  WaterTrackerWidgetState createState() => WaterTrackerWidgetState();
}

class WaterTrackerWidgetState extends State<WaterTrackerWidget> {
  double dailyWaterIntake = 0;
  double goalWaterIntake = 2000;

  @override
  void initState() {
    super.initState();
    fetchDailyWaterIntake();
  }

  void fetchDailyWaterIntake() async {
    DateTime now = DateTime.now();
    String formattedDate =
        '${now.year}-${_formatDateComponent(now.month)}-${_formatDateComponent(now.day)}';
    var url =
        Uri.http(serverUrl, '/query/daily_water', {'date': formattedDate});
    final response = await http.get(url, headers: {'cookie': cookie});
    if (response.statusCode == 200) {
      String jsonData = response.body;
      Map<String, dynamic> data = jsonDecode(jsonData);
      setState(() {
        dailyWaterIntake = data['daily_water'].toDouble();
      });
    } else {
      showAutoHideAlertDialog(context, ["Request Failed"]);
    }
  }

  void recordWaterIntake(double amount) async {
    DateTime now = DateTime.now();

    String formattedDateTime =
        '${now.year}-${_formatDateComponent(now.month)}-${_formatDateComponent(now.day)} ${_formatDateComponent(now.hour)}:${_formatDateComponent(now.minute)}:${_formatDateComponent(now.second)}';
    var url = Uri.http(serverUrl, '/record/water');
    Map<String, dynamic> data = {
      "drinking_time": formattedDateTime,
      "drinking_volume": amount
    };
    String body = json.encode(data);
    final response = await http.post(url,
        headers: {
          'cookie': cookie,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body);
    if (response.statusCode == 200) {
      setState(() {
        dailyWaterIntake += amount;
      });
    } else {
      showAutoHideAlertDialog(context, ["Request Failed"]);
    }
  }

  String _formatDateComponent(int component) {
    return component.toString().padLeft(2, '0');
  }

  String getEmoticon() {
    double percentage = dailyWaterIntake / goalWaterIntake;
    if (percentage < 0.3) {
      return '☹️';
    } else if (percentage >= 0.3 && percentage < 0.6) {
      return '😐';
    } else {
      return '😄';
    }
  }

  String getEncouragementMessage() {
    double percentage = dailyWaterIntake / goalWaterIntake;
    if (percentage < 0.3) {
      return 'Way to go, drinking lots of water helps keep you healthy!';
    } else if (percentage >= 0.3 && percentage < 0.6) {
      return 'Not even close, keep up the water habit!';
    } else {
      return 'Great, you have reached your target water intake!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Record your water intakes'),
          backgroundColor: Colors.blue,
        ),
        body: Container(
            color: Colors.blue[100],
            child: Center(
                child: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 100.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${dailyWaterIntake.toStringAsFixed(0)}ml',
                                  style: const TextStyle(fontSize: 24),
                                ),
                                Text(
                                  ' / ${goalWaterIntake.toStringAsFixed(0)}ml',
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                            const SizedBox(height: 50),
                            Center(
                              child: WaterCup(
                                  currentWater: dailyWaterIntake,
                                  goalWater: 2000,
                                  cupHeight: 200,
                                  cupWidth: 100),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      RecordWaterDialog(recordWaterIntake),
                                );
                              },
                              child: const Text('Water+'),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              getEmoticon(),
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              getEncouragementMessage(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ))))));
  }
}

class WaterCup extends StatelessWidget {
  final double currentWater;
  final double goalWater;
  final double cupHeight;
  final double cupWidth;

  const WaterCup(
      {super.key,
      required this.currentWater,
      required this.goalWater,
      required this.cupHeight,
      required this.cupWidth});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: cupHeight,
          width: cupWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(cupWidth / 10),
              topRight: Radius.circular(cupWidth / 10),
            ),
            border: Border.all(color: Colors.blue, width: cupWidth / 20),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            height: (currentWater / goalWater) * cupHeight,
            width: cupWidth,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(cupWidth / 10),
                bottomRight: Radius.circular(cupWidth / 10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RecordWaterDialog extends StatefulWidget {
  final Function(double) onRecord;

  const RecordWaterDialog(this.onRecord, {super.key});

  @override
  RecordWaterDialogState createState() => RecordWaterDialogState();
}

class RecordWaterDialogState extends State<RecordWaterDialog> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record water intakes'),
      content: TextField(
        controller: _textEditingController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(hintText: 'hydration level(ml)'),
      ),
      actions: [
        ElevatedButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text('Submit'),
          onPressed: () {
            double amount = double.tryParse(_textEditingController.text) ?? 0;
            widget.onRecord(amount);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class SleepRecordPage extends StatefulWidget {
  const SleepRecordPage({super.key});

  @override
  SleepRecordPageState createState() => SleepRecordPageState();
}

class SleepRecordPageState extends State<SleepRecordPage> {
  String selectedTimeType = 'Sleep';
  DateTime selectedTime = DateTime.now();
  DateTime sleepTime = DateFormat("HH:mm:ss").parse("23:00:00");
  int bedHour = 23;
  int bedMinute = 0;
  DateTime wakeupTime = DateFormat("HH:mm:ss").parse("08:00:00");
  int wakeHour = 8;
  int wakeMinute = 0;
  String emotion = '😊';
  String evaluation = 'Well done!';

  @override
  void initState() {
    super.initState();
    sleepTime = DateTime(selectedTime.year, selectedTime.month,
        selectedTime.day, bedHour, bedMinute, 0, 0, 0);
    wakeupTime = DateTime(selectedTime.year, selectedTime.month,
        selectedTime.day, wakeHour, wakeMinute, 0, 0, 0);
    int currentHour = int.parse(DateFormat('HH').format(selectedTime));
    if (currentHour >= 0 && currentHour <= 12) {
      selectedTimeType = "Wakeup";
    } else if (currentHour > 12 && currentHour <= 24) {
      selectedTimeType = "Sleep";
    }
    updateSelectedTime(selectedTime);
  }

  void updateSelectedTime(DateTime newTime) {
    setState(() {
      selectedTime = newTime;
      int hourDifference;
      if (selectedTimeType == 'Sleep') {
        hourDifference = selectedTime.difference(sleepTime).inMinutes.abs();
      } else {
        hourDifference = selectedTime.difference(wakeupTime).inMinutes.abs();
      }
      if (hourDifference <= 60) {
        emotion = '😊';
        evaluation = 'Great job!';
      } else if (hourDifference <= 120) {
        emotion = '😐';
        evaluation = 'Keep it up!';
      } else {
        emotion = '😢';
        evaluation = 'You can do better!';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sleep Record'),
          backgroundColor: Colors.blue,
        ),
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: selectedTimeType == 'Sleep'
                    ? const AssetImage('assets/images/moon.png')
                    : const AssetImage('assets/images/sun.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.grey.withOpacity(0.8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<String>(
                      value: selectedTimeType,
                      onChanged: (value) {
                        setState(() {
                          selectedTimeType = value!;
                          updateSelectedTime(selectedTime);
                        });
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'Sleep',
                          child: Text('Sleep Time'),
                        ),
                        DropdownMenuItem(
                          value: 'Wakeup',
                          child: Text('Wakeup Time'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedTime),
                        ).then((value) {
                          if (value != null) {
                            DateTime newSelectedTime = DateTime(
                              selectedTime.year,
                              selectedTime.month,
                              selectedTime.day,
                              value.hour,
                              value.minute,
                            );
                            updateSelectedTime(newSelectedTime);
                          }
                        });
                      },
                      child: const Text('Pick Time'),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '$selectedTimeType Time: ${DateFormat("HH:mm").format(selectedTime)}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      emotion,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      evaluation,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // 提交按钮点击事件
                        // 在这里添加处理提交的逻辑
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            )));
  }
}

class WeightRecordPage extends StatefulWidget {
  const WeightRecordPage({super.key});

  @override
  WeightRecordPageState createState() => WeightRecordPageState();
}

class WeightRecordPageState extends State<WeightRecordPage> {
  DateTime selectedDate = DateTime.now();
  double currentWeight = 0.0;
  double targetWeight = 80.0;
  double initialWeight = 71.0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Weight Record'),
          backgroundColor: Colors.green,
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/weight.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.grey.withOpacity(0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                          child: Text(
                        'Record Date:',
                        style: TextStyle(fontSize: 18),
                      )),
                      const SizedBox(height: 8),
                      Center(
                          child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.green),
                        ),
                        onPressed: _selectDate,
                        child: Text(DateFormat.yMMMd().format(selectedDate)),
                      )),
                      const SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Current Weight (kg)',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your current weight';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  if (value.isEmpty) {
                                    currentWeight = 0.0;
                                  } else {
                                    currentWeight = double.parse(value);
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.green),
                              ),
                              onPressed: _submitData,
                              child: const Text('Submit'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Current Weight:',
                              style: TextStyle(fontSize: 18)),
                          Text('$currentWeight kg',
                              style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Target Weight: $targetWeight kg',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Start Weight: $initialWeight kg',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 16),
                      Center(
                          child: SizedBox(
                        width: 100,
                        height: 100,
                        child: CustomPaint(
                          painter: WeightProgress(
                            targetWeight: targetWeight,
                            currentWeight: currentWeight,
                            initialWeight: initialWeight,
                          ),
                        ),
                      )),
                      const SizedBox(height: 16),
                      Center(child: _buildEmoji()),
                      const SizedBox(height: 8),
                      Center(child: _buildEncouragement()),
                    ],
                  ),
                ),
              ),
            )));
  }

  void _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void _submitData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    String formattedDate = DateFormat('yyyy-M-d').format(selectedDate);

    var url = Uri.http(serverUrl, '/record/body');
    Map<String, dynamic> data = {
      "date": formattedDate,
      "weight": currentWeight
    };
    String body = json.encode(data);
    final response = await http.post(url,
        headers: {
          'cookie': cookie,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body);
    if (response.statusCode == 200) {
      return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: const Text('You just have your WEIGHT recorded!'),
          actions: <TextButton>[
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyStatefulWidget(
                      initialWidget: 'A',
                    ),
                  ),
                );
              },
              child: const Text('Close'),
            )
          ],
        ),
      );
    } else {
      showAutoHideAlertDialog(context, ["Request Failed"]);
    }
  }

  Widget _buildEmoji() {
    double difference = ((currentWeight - initialWeight)) /
        ((targetWeight - initialWeight).abs());
    if (difference >= 0.7) {
      return const Text('😊', style: TextStyle(fontSize: 48));
    } else if (difference >= 0.3) {
      return const Text('😐', style: TextStyle(fontSize: 48));
    } else {
      return const Text('😢', style: TextStyle(fontSize: 48));
    }
  }

  Widget _buildEncouragement() {
    double difference = (currentWeight - targetWeight).abs();
    if (difference <= 5.0) {
      return const Text('Keep up the good work!');
    } else if (difference <= 10.0) {
      return const Text('You are making progress!');
    } else {
      return const Text('Don\'t give up! Keep going!');
    }
  }
}

class WeightProgress extends CustomPainter {
  final double targetWeight;
  final double currentWeight;
  final double initialWeight;

  WeightProgress(
      {required this.targetWeight,
      required this.currentWeight,
      required this.initialWeight});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.shortestSide / 2;
    const double strokeWidth = 10;
    final double progressRaw =
        (currentWeight - initialWeight) / (targetWeight - initialWeight);
    final double progress = progressRaw < 0 ? 0 : progressRaw;
    const double startAngle = -pi / 2;
    final double sweepAngle = 2 * pi * progress;

    Paint backgroundPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    Paint progressPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    Rect rect = Rect.fromCircle(
        center: Offset(radius, radius), radius: radius - strokeWidth / 2);

    canvas.drawArc(rect, 0, 2 * pi, false, backgroundPaint);
    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);

    String progressText = '${(progress * 100).toStringAsFixed(1)}%';
    if (progressRaw < 0) {
      progressText = '0%';
    }

    TextSpan progressSpan = TextSpan(
      text: progressText,
      style: const TextStyle(
          color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
    );
    TextPainter progressPainter = TextPainter(
      text: progressSpan,
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );
    progressPainter.layout();
    progressPainter.paint(
      canvas,
      Offset(radius - progressPainter.width / 2,
          radius - progressPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class MealRecordPage extends StatefulWidget {
  const MealRecordPage({super.key});

  @override
  MealRecordPageState createState() => MealRecordPageState();
}

class MealRecordPageState extends State<MealRecordPage> {
  String selectedMealType = 'Breakfast';
  DateTime selectedDate = DateTime.now();
  DateTime selectedTime = DateTime.now();
  DateTime bTime = DateFormat("HH:mm:ss").parse("08:00:00");
  int bHour = 8;
  int bMinute = 0;
  DateTime lTime = DateFormat("HH:mm:ss").parse("12:00:00");
  int lHour = 12;
  int lMinute = 0;
  DateTime dTime = DateFormat("HH:mm:ss").parse("18:00:00");
  int dHour = 18;
  int dMinute = 0;
  String emotion = '😊';
  String evaluation = 'Well done!';

  @override
  void initState() {
    super.initState();
    bTime = DateTime(selectedTime.year, selectedTime.month, selectedTime.day,
        bHour, bMinute, 0, 0, 0);
    lTime = DateTime(selectedTime.year, selectedTime.month, selectedTime.day,
        lHour, lMinute, 0, 0, 0);
    dTime = DateTime(selectedTime.year, selectedTime.month, selectedTime.day,
        dHour, dMinute, 0, 0, 0);
    int currentHour = int.parse(DateFormat('HH').format(selectedTime));
    if (currentHour >= 0 && currentHour <= 10) {
      selectedMealType = "Wakeup";
    } else if (currentHour > 10 && currentHour <= 16) {
      selectedMealType = "Lunch";
    } else if (currentHour > 16 && currentHour <= 24) {
      selectedMealType = "Dinner";
    }
    updateSelectedTime(selectedTime);
  }

  void updateSelectedTime(DateTime newTime) {
    setState(() {
      selectedTime = newTime;
      int hourDifference;
      if (selectedMealType == 'Breakfast') {
        hourDifference = selectedTime.difference(bTime).inMinutes.abs();
      } else if (selectedMealType == 'Lunch') {
        hourDifference = selectedTime.difference(lTime).inMinutes.abs();
      } else {
        hourDifference = selectedTime.difference(dTime).inMinutes.abs();
      }
      if (hourDifference <= 60) {
        emotion = '😊';
        evaluation = 'Impressive commitment to punctual meal times!';
      } else if (hourDifference <= 120) {
        emotion = '😐';
        evaluation = 'Flexibility is key in meal times. Strive for balance!';
      } else {
        emotion = '😢';
        evaluation = 'Make meal times a priority for a healthy lifestyle.';
      }
    });
  }

  void _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void postData() async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final String formattedTime = DateFormat('HH:mm:ss').format(selectedTime);
    final String mealTime = '$formattedDate $formattedTime';
    var url = Uri.http(serverUrl, '/record/meal');
    Map<String, dynamic> data = {
      "meal_time": mealTime,
      "meal_content": selectedMealType
    };
    String body = json.encode(data);
    try {
      final response = await http.post(url,
          headers: {
            'cookie': cookie,
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: body);
      if (response.statusCode == 200) {
        return showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            content: const Text('You just have your MEALTIME recorded!'),
            actions: <TextButton>[
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyStatefulWidget(
                        initialWidget: 'A',
                      ),
                    ),
                  );
                },
                child: const Text('Close'),
              )
            ],
          ),
        );
      } else {
        showAutoHideAlertDialog(context, ["Request Failed"]);
      }
    } catch (e) {
      showAutoHideAlertDialog(context, ["Failed", "Server unavailable now"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Meal Timing Record'),
          backgroundColor: Colors.green,
        ),
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(selectedMealType == 'Breakfast'
                    ? 'assets/images/b.png'
                    : selectedMealType == 'Lunch'
                        ? 'assets/images/l.png'
                        : 'assets/images/d.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.grey.withOpacity(0.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: DropdownButton<String>(
                              value: selectedMealType,
                              onChanged: (value) {
                                setState(() {
                                  selectedMealType = value!;
                                  updateSelectedTime(selectedTime);
                                });
                              },
                              items: const [
                                DropdownMenuItem(
                                  value: 'Breakfast',
                                  child: Text('Breakfast Time'),
                                ),
                                DropdownMenuItem(
                                  value: 'Lunch',
                                  child: Text('Lunch Time'),
                                ),
                                DropdownMenuItem(
                                  value: 'Dinner',
                                  child: Text('Dinner Time'),
                                ),
                              ],
                            ))),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                      ),
                      onPressed: _selectDate,
                      child: Text(DateFormat.yMMMd().format(selectedDate)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                      ),
                      onPressed: () {
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedTime),
                        ).then((value) {
                          if (value != null) {
                            DateTime newSelectedTime = DateTime(
                              selectedTime.year,
                              selectedTime.month,
                              selectedTime.day,
                              value.hour,
                              value.minute,
                            );
                            updateSelectedTime(newSelectedTime);
                          }
                        });
                      },
                      child: const Text('Choose your meal time！'),
                    ),
                    const SizedBox(height: 20),
                    Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey.withOpacity(0.8),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              '$selectedMealType Time: ${DateFormat("HH:mm").format(selectedTime)}',
                              style: const TextStyle(fontSize: 20),
                            ))),
                    const SizedBox(height: 20),
                    Text(
                      emotion,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 10),
                    Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey.withOpacity(0.8),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              evaluation,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ))),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                      ),
                      onPressed: postData,
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            )));
  }
}

class ExeRecordPage extends StatefulWidget {
  const ExeRecordPage({super.key});

  @override
  ExeRecordPageState createState() => ExeRecordPageState();
}

class ExeRecordPageState extends State<ExeRecordPage> {
  String selectedExeType = 'Running';
  DateTime selectedDate = DateTime.now();
  DateTime selectedTime = DateTime.now();
  String emotion = '😊';
  String evaluation = 'Well done!';
  int exeduration = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  void updateSelectedTime(DateTime newTime) {
    setState(() {
      selectedTime = newTime;
    });
  }

  void updateDuration(int duration) {
    setState(() {
      if (duration >= 120) {
        emotion = '😊';
        evaluation = 'Fantastic job on your long workout!';
      } else if (duration >= 60) {
        emotion = '😐';
        evaluation = 'You are doing amazing!';
      } else {
        emotion = '😢';
        evaluation = 'Keep it up!';
      }
    });
  }

  void _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void postData() async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final String formattedTime = DateFormat('HH:mm:ss').format(selectedTime);
    final String exeTime = '$formattedDate $formattedTime';
    var url = Uri.http(serverUrl, '/record/exercise');
    Map<String, dynamic> data = {
      "exercise_time": exeTime,
      "exercise_type": selectedExeType,
      "exercise_amount": exeduration
    };
    String body = json.encode(data);
    try {
      final response = await http.post(url,
          headers: {
            'cookie': cookie,
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: body);
      if (response.statusCode == 200) {
        return showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            content: const Text('You just have your EXERCISE recorded!'),
            actions: <TextButton>[
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyStatefulWidget(
                        initialWidget: 'A',
                      ),
                    ),
                  );
                },
                child: const Text('Close'),
              )
            ],
          ),
        );
      } else {
        showAutoHideAlertDialog(context, ["Request Failed"]);
      }
    } catch (e) {
      showAutoHideAlertDialog(context, ["Failed", "Server unavailable now"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Meal Timing Record'),
          backgroundColor: Colors.greenAccent,
        ),
        body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/run.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.grey.withOpacity(0.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: DropdownButton<String>(
                              value: selectedExeType,
                              onChanged: (value) {
                                setState(() {
                                  selectedExeType = value!;
                                  updateSelectedTime(selectedTime);
                                });
                              },
                              items: const [
                                DropdownMenuItem(
                                  value: 'Running',
                                  child: Text('Running'),
                                ),
                                DropdownMenuItem(
                                  value: 'Cycling',
                                  child: Text('Cycling'),
                                ),
                                DropdownMenuItem(
                                  value: 'Swimming',
                                  child: Text('Swimming'),
                                ),
                                DropdownMenuItem(
                                  value: 'Yoga',
                                  child: Text('Yoga'),
                                ),
                                DropdownMenuItem(
                                  value: 'Basketball',
                                  child: Text('Basketball'),
                                ),
                                DropdownMenuItem(
                                  value: 'Soccer',
                                  child: Text('Soccer'),
                                ),
                                DropdownMenuItem(
                                  value: 'Ping-Pong',
                                  child: Text('Ping-Pong'),
                                ),
                                DropdownMenuItem(
                                  value: 'Tennis',
                                  child: Text('Tennis'),
                                ),
                              ],
                            ))),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                      ),
                      onPressed: _selectDate,
                      child: Text(DateFormat.yMMMd().format(selectedDate)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                      ),
                      onPressed: () {
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedTime),
                        ).then((value) {
                          if (value != null) {
                            DateTime newSelectedTime = DateTime(
                              selectedTime.year,
                              selectedTime.month,
                              selectedTime.day,
                              value.hour,
                              value.minute,
                            );
                            updateSelectedTime(newSelectedTime);
                          }
                        });
                      },
                      child: const Text('Exercise Time'),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Exercise Duration (min)',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your exercise duration';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                if (value.isEmpty) {
                                  exeduration = 0;
                                } else {
                                  exeduration = int.parse(value);
                                }
                                updateDuration(exeduration);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey.withOpacity(0.8),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              '$selectedExeType Time: $exeduration',
                              style: const TextStyle(fontSize: 20),
                            ))),
                    const SizedBox(height: 20),
                    Text(
                      emotion,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 10),
                    Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey.withOpacity(0.8),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              evaluation,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ))),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                      ),
                      onPressed: postData,
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            )));
  }
}
