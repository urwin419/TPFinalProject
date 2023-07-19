// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'other.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  PlanPagestate createState() => PlanPagestate();
}

class PlanPagestate extends State<PlanPage> {
  final String _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  List<bool> completeness = [false, false, false, false, false];
  final TextEditingController _weightController =
      TextEditingController(text: "60");
  final TextEditingController _startweightController =
      TextEditingController(text: "80");
  final TextEditingController _breakfastController =
      TextEditingController(text: "8:00");
  final TextEditingController _lunchController =
      TextEditingController(text: "12:00");
  final TextEditingController _dinnerController =
      TextEditingController(text: "18:00");
  final TextEditingController _exetimeController =
      TextEditingController(text: "150");
  final TextEditingController _waterController =
      TextEditingController(text: "2000");
  final TextEditingController _sleepController =
      TextEditingController(text: "23:00");
  final TextEditingController _wakeController =
      TextEditingController(text: "8:00");
  Widget buildTimePicker(
    String label,
    TimeOfDay time,
    ValueChanged<TimeOfDay> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        ElevatedButton(
          onPressed: () {
            showTimePicker(
              context: context,
              initialTime: time,
            ).then((selectedTime) {
              if (selectedTime != null) {
                onChanged(selectedTime);
              }
            });
          },
          child: Text(
            time.format(context),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _breakfastController.dispose();
    _lunchController.dispose();
    _dinnerController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      controller.text = pickedTime.format(context);
    }
  }

  Future<void> _sendDataRequest() async {
    Map<String, dynamic> data = {
      "plan_date": _currentDate,
      "weight": _weightController.text,
      "breakfast_time": _breakfastController.text,
      "lunch_time": _lunchController.text,
      "dinner_time": _dinnerController.text,
      "exercise_amount": _exetimeController.text,
      "water": _waterController.text,
      "bed_time": _sleepController.text,
      "wake_up_time": _wakeController.text,
      "start_weight": _startweightController.text,
    };
    String body = json.encode(data);
    String? cookieValue = await storage.read(key: 'cookie');
    String cookie = cookieValue ?? '';
    var response = await http.post(
      Uri.parse('$serverUrl/record/plan'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'cookie': cookie
      },
      body: body,
    );
    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainPage(),
        ),
      );
    } else {
      showAutoHideAlertDialog(
          context, ["Saving failed", "Server unavailable now"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Prizes',
        theme: ThemeData(
          primaryColor: Colors.green[900],
          scaffoldBackgroundColor: Colors.green[800],
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Plan'),
            backgroundColor: Colors.green,
          ),
          body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/plan.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CardListItem(
                    icon: Icons.monitor_weight,
                    title: 'Weight',
                    subtitle: 'Manage your weight',
                    isCompleted: completeness[0],
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) => AlertDialog(
                          title: const Text('SET YOUR IDEAL WEIGHT'),
                          content: SizedBox(
                              height: 150,
                              child: Column(children: [
                                Expanded(
                                    child: TextFormField(
                                  controller: _weightController,
                                  inputFormatters: [
                                    NumberTextInputFormatter(
                                      integerDigits: 4,
                                      decimalDigits: 2,
                                      maxValue: '1000.00',
                                      decimalSeparator: '.',
                                      groupDigits: 3,
                                      groupSeparator: ',',
                                      allowNegative: false,
                                      overrideDecimalPoint: true,
                                      insertDecimalPoint: false,
                                      insertDecimalDigits: true,
                                    ),
                                  ],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'WEIGHT GOAL(kg)',
                                    hintText: '80.0',
                                  ),
                                )),
                                Expanded(
                                    child: TextFormField(
                                  controller: _startweightController,
                                  inputFormatters: [
                                    NumberTextInputFormatter(
                                      integerDigits: 4,
                                      decimalDigits: 2,
                                      maxValue: '1000.00',
                                      decimalSeparator: '.',
                                      groupDigits: 3,
                                      groupSeparator: ',',
                                      allowNegative: false,
                                      overrideDecimalPoint: true,
                                      insertDecimalPoint: false,
                                      insertDecimalDigits: true,
                                    ),
                                  ],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'START WEIGHT(kg)',
                                    hintText: '80.0',
                                  ),
                                )),
                              ])),
                          actions: [
                            ElevatedButton(
                              child: const Text('CANCEL'),
                              onPressed: () {
                                setState(() {
                                  completeness[0] = false;
                                });
                                _weightController.text = '60';
                                Navigator.pop(dialogContext);
                              },
                            ),
                            ElevatedButton(
                              child: const Text('OK'),
                              onPressed: () {
                                setState(() {
                                  completeness[0] = true;
                                });
                                Navigator.pop(dialogContext);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  CardListItem(
                    icon: Icons.access_time,
                    title: 'Mealtime',
                    subtitle: 'Manage meal timings',
                    isCompleted: completeness[1],
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) => AlertDialog(
                          title: const Text('Manage your meal timings'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          content: SizedBox(
                              child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: _breakfastController,
                                readOnly: true,
                                onTap: () {
                                  _selectTime(context, _breakfastController);
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Breakfast Time',
                                ),
                              ),
                              TextFormField(
                                controller: _lunchController,
                                readOnly: true,
                                onTap: () {
                                  _selectTime(context, _lunchController);
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Lunch Time',
                                ),
                              ),
                              TextFormField(
                                controller: _dinnerController,
                                readOnly: true,
                                onTap: () {
                                  _selectTime(context, _dinnerController);
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Dinner Time',
                                ),
                              ),
                              const SizedBox(height: 12.0),
                            ],
                          )),
                          actions: [
                            ElevatedButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                setState(() {
                                  completeness[1] = false;
                                });
                                _breakfastController.text = '8:00';
                                _lunchController.text = '12:00';
                                _dinnerController.text = '18:00';
                                Navigator.pop(dialogContext);
                              },
                            ),
                            ElevatedButton(
                              child: const Text('OK'),
                              onPressed: () {
                                setState(() {
                                  completeness[1] = true;
                                });
                                Navigator.pop(dialogContext);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  CardListItem(
                    icon: Icons.fitness_center,
                    title: 'Exercise',
                    subtitle: 'Track your workout',
                    isCompleted: completeness[2],
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) => AlertDialog(
                          title:
                              const Text('Set your exercise goal for a week'),
                          content: TextField(
                            controller: _exetimeController,
                            inputFormatters: [
                              NumberTextInputFormatter(
                                integerDigits: 5,
                                decimalDigits: 0,
                                maxValue: '10080',
                                decimalSeparator: '.',
                                groupDigits: 3,
                                groupSeparator: ',',
                                allowNegative: false,
                                overrideDecimalPoint: true,
                                insertDecimalPoint: false,
                                insertDecimalDigits: true,
                              ),
                            ],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Exeercise Duration (min)',
                              hintText: '150',
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                setState(() {
                                  completeness[2] = false;
                                });
                                _exetimeController.text = '150';
                                Navigator.pop(dialogContext);
                              },
                            ),
                            ElevatedButton(
                              child: const Text('OK'),
                              onPressed: () {
                                setState(() {
                                  completeness[2] = true;
                                });
                                Navigator.pop(dialogContext);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  CardListItem(
                    icon: Icons.local_drink,
                    title: 'Water',
                    subtitle: 'Stay hydrated',
                    isCompleted: completeness[3],
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) => AlertDialog(
                          title:
                              const Text('Set your daily water dringking goal'),
                          content: TextField(
                            controller: _waterController,
                            inputFormatters: [
                              NumberTextInputFormatter(
                                integerDigits: 4,
                                decimalDigits: 0,
                                maxValue: '1000',
                                decimalSeparator: '.',
                                groupDigits: 3,
                                groupSeparator: ',',
                                allowNegative: false,
                                overrideDecimalPoint: true,
                                insertDecimalPoint: false,
                                insertDecimalDigits: true,
                              ),
                            ],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Water (ml)',
                              hintText: '2000',
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                setState(() {
                                  completeness[3] = false;
                                });
                                _waterController.text = '2000';
                                Navigator.pop(dialogContext);
                              },
                            ),
                            ElevatedButton(
                              child: const Text('OK'),
                              onPressed: () {
                                setState(() {
                                  completeness[3] = true;
                                });
                                Navigator.pop(dialogContext);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  CardListItem(
                    icon: Icons.hotel,
                    title: 'Sleep',
                    subtitle: 'Manage sleep schedule',
                    isCompleted: completeness[4],
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) => AlertDialog(
                          title: const Text('Set your sleep timings'),
                          content: SizedBox(
                              child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: _sleepController,
                                readOnly: true,
                                onTap: () {
                                  _selectTime(context, _sleepController);
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Go to bed',
                                ),
                              ),
                              TextFormField(
                                controller: _wakeController,
                                readOnly: true,
                                onTap: () {
                                  _selectTime(context, _wakeController);
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Wake up',
                                ),
                              ),
                              const SizedBox(height: 12.0),
                            ],
                          )),
                          actions: [
                            ElevatedButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                setState(() {
                                  completeness[4] = false;
                                });
                                _sleepController.text = "23:00";
                                _wakeController.text = "8:00";
                                Navigator.pop(dialogContext);
                              },
                            ),
                            ElevatedButton(
                              child: const Text('OK'),
                              onPressed: () {
                                setState(() {
                                  completeness[4] = true;
                                });
                                Navigator.pop(dialogContext);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.all(16.0), // 设置所需的填充值
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.green),
                                ),
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ))),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.all(16.0), // 设置所需的填充值
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.green),
                                ),
                                child: const Text('Comfirm'),
                                onPressed: () {
                                  if (completeness
                                      .every((element) => element == true)) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext dialogContext) =>
                                            AlertDialog(
                                              title: const Text('YOUR PLAN'),
                                              content: SingleChildScrollView(
                                                  child: Column(
                                                children: [
                                                  Text(
                                                      'WEIGHT: ${_weightController.text}kg'),
                                                  Text(
                                                      'BREAKFAST: ${_breakfastController.text}'),
                                                  Text(
                                                      'LUNCH: ${_lunchController.text}'),
                                                  Text(
                                                      'DINNER: ${_dinnerController.text}'),
                                                  Text(
                                                      'EXERCISE: ${_exetimeController.text} min'),
                                                  Text(
                                                      'WATER: ${_waterController.text} ml'),
                                                  Text(
                                                      'BED: ${_sleepController.text}'),
                                                  Text(
                                                      'WAKEUP: ${_wakeController.text}'),
                                                ],
                                              )),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('CANCEL'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    _sendDataRequest();
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('SUBMIT'),
                                                ),
                                              ],
                                            ));
                                  } else {
                                    showAutoHideAlertDialog(context, [
                                      "WARNING",
                                      "YOU HAVE NOT FINISHED YOUR PLAN"
                                    ]);
                                  }
                                },
                              ))),
                    ],
                  ),
                ],
              )),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back),
          ),
        ));
  }
}

class CardListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isCompleted;

  const CardListItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: 0.8, // 设置透明度为0.5，表示半透明
        child: Card(
          elevation: 2.0,
          child: ListTile(
            leading: Icon(icon, size: 40),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: isCompleted ? const Icon(Icons.check) : null,
            subtitle: Text(subtitle),
            onTap: onTap,
          ),
        ));
  }
}
