// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:group_project/request.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'records.dart';
import 'dart:ui' as ui;

import 'view.dart';

class ViewAllPage extends StatefulWidget {
  const ViewAllPage({super.key});

  @override
  ViewAllPageState createState() => ViewAllPageState();
}

class ViewAllPageState extends State<ViewAllPage> {
  List<Map<String, dynamic>> records = [];

  @override
  void initState() {
    super.initState();
  }

  Widget _buildHealthScoreModule() {
    Color numberColor = getGradientColor(
        scores["total_score"].toInt(), 0, 100, Colors.red, Colors.green);
    return SizedBox(
        width: 300,
        height: 100,
        child: Center(
            child: Card(
          shape: const StadiumBorder(
            side: BorderSide(
              color: Colors.grey,
              width: 2.0,
            ),
          ),
          elevation: 2,
          child: ListTile(
            title: const Text(
              'Health Score',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            trailing: Text(
              scores["total_score"].toInt().toString(),
              style: TextStyle(
                color: numberColor,
                fontSize: 30,
              ),
            ),
          ),
        )));
  }

  Widget _buildRecordModule(
      {required String label,
      required String prefix,
      required String value,
      required String type,
      required String score}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(
          color: Colors.grey,
          width: 1.0,
        ),
      ),
      child: ListTile(
          title: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$prefix: $value',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                child: const Text('View all'),
                onPressed: () async {
                  records = (await fetchRecord(type))!;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewAll(
                              records: records,
                              type: type,
                            )),
                  );
                },
              ),
            ],
          ),
          trailing: Text(
            score,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('View All Records'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHealthScoreModule(),
          _buildRecordModule(
              label: 'Weight',
              type: 'body',
              prefix: latestRecord['body']['date'].toString(),
              value: '${latestRecord['body']['weight']} kg',
              score: scores["bmi"].toInt().toString()),
          _buildRecordModule(
              label: 'MealTiming',
              type: 'meal',
              prefix: '${latestRecord['meal']['meal_date']}',
              value:
                  '\nBreakfast Time: ${latestRecord['meal']['breakfast_time']}\nLunch Time: ${latestRecord['meal']['lunch_time']}\nDinner Time: ${latestRecord['meal']['dinner_time']}',
              score: scores["meal"].toInt().toString()),
          _buildRecordModule(
              label: 'Exercise',
              type: 'exercise',
              prefix: latestRecord['exercise']['exercise_time'],
              value:
                  '\n${latestRecord['exercise']['exercise_type']} for ${latestRecord['exercise']['exercise_amount']} mins',
              score: scores["exercise"].toInt().toString()),
          _buildRecordModule(
              label: 'Water',
              type: 'water',
              prefix: latestRecord['water']['drinking_time'],
              value: '${latestRecord['water']['drinking_volume']} ml',
              score: scores["water"].toInt().toString()),
          _buildRecordModule(
              label: 'Sleep',
              type: 'sleep',
              prefix: 'Sleep',
              value:
                  'from ${latestRecord['sleep']['bed_time']} \nto ${latestRecord['sleep']['wake_up_time']}',
              score: scores["sleep"].toInt().toString()),
        ],
      ),
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

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  List<dynamic> chatHistory = [];
  late bool _isLoading;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    fetchQAHistory();
  }

  Future<void> fetchQAHistory() async {
    setState(() {
      _isLoading = true;
    });
    try {
      String? cookieValue = await storage.read(key: 'cookie');
      String cookie = cookieValue ?? '';
      final response = await http.get(
          Uri.parse('$serverUrl/query/qa_history?num=10&with_context=false'),
          headers: {
            'cookie': cookie,
            'Content-Type': 'application/json; charset=UTF-8',
          });
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List qaHistory = jsonData['history'];
        if (qaHistory.isNotEmpty) {
          chatHistory = qaHistory;
        } else {
          chatHistory = [
            {
              "answer": "Ask your first question!",
              "qa_time": "2023-07-09 00:00:00",
              "question": "COME!"
            }
          ];
        }
        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception('Unexpected error occured!');
      }
    } catch (e) {
      throw Exception('Unexpected error occured!');
    }
  }

  void postAnswer(question) async {
    setState(() {
      _isLoading = true;
    });
    String formattedTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    Map<String, dynamic> data = {
      "qa_time": formattedTime,
      "question": question
    };
    String body = json.encode(data);
    String? cookieValue = await storage.read(key: 'cookie');
    String cookie = cookieValue ?? '';
    try {
      final response = await http.post(Uri.parse('$serverUrl/query/NLP_QA'),
          headers: {
            'cookie': cookie,
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: body);
      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception('Unexpected error occured!');
      }
    } catch (e) {
      throw Exception('Unexpected error occured!');
    }
  }

  Future<void> _refreshChatHistory() async {
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      fetchQAHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
            color: Colors.green,
          ))
        : RefreshIndicator(
            onRefresh: _refreshChatHistory,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: chatHistory.length * 2,
                    itemBuilder: (BuildContext context, int index) {
                      final chat =
                          chatHistory[(chatHistory.length - 1) - (index ~/ 2)];
                      final bool isUser = index % 2 == 1;
                      if (isUser && chat['answer'] == null) {
                        return Container();
                      }
                      final String message =
                          isUser ? chat['answer']! : chat['question']!;
                      return Bubble(
                        message: message,
                        isUser: !isUser,
                      );
                    },
                  ),
                ),
                Container(
                  color: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textEditingController,
                          decoration: const InputDecoration(
                            hintText: 'How can I help you?',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          String userMessage =
                              _textEditingController.text.trim();
                          setState(() {
                            postAnswer(userMessage);
                            fetchQAHistory();
                            _textEditingController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ));
  }
}

class Bubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const Bubble({
    Key? key,
    required this.message,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 2 / 3,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isUser ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            child: /*TypewriterText(
            text:
                message),*/
                Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ));
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget({super.key});

  @override
  BottomSheetWidgetState createState() => BottomSheetWidgetState();
}

class BottomSheetWidgetState extends State<BottomSheetWidget> {
  final List<String> _images = [
    'assets/images/meal.jpg',
    'assets/images/water.jpg',
    'assets/images/weight.jpg',
    'assets/images/sleep.jpg',
    'assets/images/exe.jpg',
    'assets/images/mood.png',
  ];

  Widget _buildButton(String title, String image, String w) {
    return Card(
      child: InkWell(
        onTap: () {
          switch (w) {
            case 'wei':
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const WeightRecordPage()),
              );
              break;
            case 'meal':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MealRecordPage()),
              );
              break;
            case 'exe':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExeRecordPage()),
              );
              break;
            case 'mood':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MoodPage(),
                ),
              );
              break;
            case 'water':
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const WaterTrackerWidget()),
              );
              break;
            case 'sleep':
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SleepRecordPage()),
              );
              break;
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var targetHeight = screenHeight * 3 / 5;
    return Container(
      height: targetHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 20.0,
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              children: <Widget>[
                _buildButton('MEAL', _images[0], 'meal'),
                _buildButton('WATER', _images[1], 'water'),
                _buildButton('WEIGHT', _images[2], 'wei'),
                _buildButton('SLEEP', _images[3], 'sleep'),
                _buildButton('EXERCISE', _images[4], 'exe'),
                _buildButton('MOOD', _images[5], 'mood'),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  CalendarViewState createState() => CalendarViewState();
}

class CalendarViewState extends State<CalendarView> {
  late DateTime _selectedDay;
  late Map<String, dynamic> _events;
  late bool _isLoading;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _events = {};
    _isLoading = false;
    _fetchEvents();
  }

  String _formatDateComponent(int component) {
    return component.toString().padLeft(2, '0');
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
    });
    String formattedDate =
        '${_selectedDay.year}-${_formatDateComponent(_selectedDay.month)}-${_formatDateComponent(_selectedDay.day)}';

    try {
      String? cookieValue = await storage.read(key: 'cookie');
      String cookie = cookieValue ?? '';
      final response = await http.get(
          Uri.parse('$serverUrl/query/daily_record?date=$formattedDate'),
          headers: {
            'cookie': cookie,
            'Content-Type': 'application/json; charset=UTF-8',
            'Connection': 'keep-alive'
          });
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _isLoading = false;
          _events = jsonData;
        });
      } else {
        setState(() {
          _isLoading = false;
          _events = {};
        });
        throw Exception('Unexpected error occured!');
      }
    } catch (e) {
      throw Exception('Unexpected error occured!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Center(
            child: Column(children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _fetchEvents();
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const CircularProgressIndicator(
                  color: Colors.green,
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: _events.length,
                    itemBuilder: (BuildContext context, int index) {
                      String category = _events.keys.elementAt(index);
                      dynamic categoryData = _events[category];
                      if (category == 'exercise' || category == 'water') {
                        return ExpansionTile(
                          title: Text(category),
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: categoryData.length,
                              itemBuilder: (BuildContext context, int index) {
                                Map<String, dynamic> categoryDatas =
                                    categoryData[index];
                                return ExpansionTile(
                                  title: Text((index + 1).toString()),
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const ClampingScrollPhysics(),
                                      itemCount: categoryDatas.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        String field =
                                            categoryDatas.keys.elementAt(index);
                                        dynamic value = categoryDatas[field];
                                        return ListTile(
                                          title: Text(field),
                                          subtitle: Text(value.toString()),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        );
                      } else {
                        return ExpansionTile(
                          title: Text(category),
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: categoryData.length,
                              itemBuilder: (BuildContext context, int index) {
                                Map<String, dynamic> categoryDatas =
                                    categoryData[0];
                                String field =
                                    categoryDatas.keys.elementAt(index);
                                dynamic value = categoryDatas[field];
                                return ListTile(
                                  title: Text(field),
                                  subtitle: Text(value.toString()),
                                );
                              },
                            ),
                          ],
                        );
                      }
                    },
                  ),
                )
        ])));
  }
}

class ThreeQuarterCircularProgressPainter extends CustomPainter {
  double progress;
  Color backgroundColor;
  Color progressColor;
  double strokeWidth;
  double fontSize;

  ThreeQuarterCircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
    required this.fontSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;
    Offset center = Offset(size.width / 2, size.height);

    // 背景圆环
    Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi * 5 / 4,
      pi / 2,
      false,
      backgroundPaint,
    );

    // 进度圆弧
    Paint progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    double sweepAngle = (pi * 2 - pi / 2) * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi / 4,
      -sweepAngle,
      false,
      progressPaint,
    );

    // 进度文本
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: (progress * 100).toInt().toString(),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: progressColor,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    double textX = center.dx - textPainter.width / 2;
    double textY = center.dy - textPainter.height / 2;
    textPainter.paint(canvas, Offset(textX, textY));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final Duration duration;

  final bool isMounted;

  const TypewriterText(
      {super.key,
      required this.text,
      this.isMounted = false,
      this.duration = const Duration(milliseconds: 100)});

  @override
  TypewriterTextState createState() => TypewriterTextState();
}

class TypewriterTextState extends State<TypewriterText> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isMounted) {
      Timer.periodic(widget.duration, (Timer timer) {
        setState(() {
          _index++;
        });
        if (_index >= widget.text.length) {
          timer.cancel();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayText = widget.text.substring(0, _index);

    return Text(displayText);
  }
}

class CircularProgress extends StatelessWidget {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  const CircularProgress({
    super.key,
    this.progress = 0.0,
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.blue,
    this.strokeWidth = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CircularProgressPainter(
        progress: progress,
        backgroundColor: backgroundColor,
        progressColor: progressColor,
        strokeWidth: strokeWidth,
      ),
      size: const Size.square(200),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  double progress;
  Color backgroundColor;
  Color progressColor;
  double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;
    Offset center = Offset(size.width / 2, size.height / 2);

    Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, backgroundPaint);

    Paint progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    double sweepAngle = 2 * pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

showAutoHideAlertDialog(BuildContext context, List<String> texts) {
  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    content: SizedBox(
      height: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 10),
          Text(texts[0],
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(texts[1],
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    ),
    backgroundColor: Colors.white,
    elevation: 8,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop(true);
      });
      return WillPopScope(
        onWillPop: () async => false,
        child: alert,
      );
    },
  );
}

Color getGradientColor(
    int value, int minValue, int maxValue, Color startColor, Color endColor) {
  value = value.clamp(minValue, maxValue);
  double ratio = (value - minValue) / (maxValue - minValue);
  int r = (startColor.red + (endColor.red - startColor.red) * ratio).toInt();
  int g =
      (startColor.green + (endColor.green - startColor.green) * ratio).toInt();
  int b = (startColor.blue + (endColor.blue - startColor.blue) * ratio).toInt();
  Color gradientColor = Color.fromARGB(255, r, g, b);
  return gradientColor;
}
