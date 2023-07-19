// ignore_for_file: unused_import, library_private_types_in_public_api, use_build_context_synchronously, invalid_use_of_visible_for_testing_member, unused_field, unnecessary_import

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'records.dart';
import 'profile.dart';
import 'request.dart';
import 'login.dart';
import 'register.dart';
import 'prize.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'plan.dart';
import 'view.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'other.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

const serverUrl = 'https://18.162.169.56:23718';
Map<String, dynamic> latestRecord = {};
Map<String, dynamic> plan = {};
Map<String, dynamic> scores = {};
const storage = FlutterSecureStorage();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const MainPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/1.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/logo.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  width: 250,
                  height: 250,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Health Monitoring & Exercise Recording Application \n with Intelligent Assistant Based on BERT Model',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 55, 54, 54),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 100,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            ),
            child: const Text(
              'WELCOME',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _textEditingController = TextEditingController();
  int _selectedIndex = 0;
  late Widget selectedWidget = _main();
  final List<String> _images = [
    'assets/images/meal.jpg',
    'assets/images/water.jpg',
    'assets/images/weight.jpg',
    'assets/images/sleep.jpg',
    'assets/images/exe.jpg',
    'assets/images/mood.png',
  ];
  final List<String> entries3 = <String>[
    'Plans',
    'Profile',
    'Prizes',
    'Logout'
  ];

  late final List<AnimationController> _controllers = [];
  bool shouldShowButton = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 4; i++) {
      _controllers.add(AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ));
    }
    shouldShowButton = true;
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onNavItemTapped(int index) async {
    await fetchScores(context);
    setState(() {
      _selectedIndex = index;

      if (index == 0) {
        shouldShowButton = true;
        selectedWidget = _main();
      } else if (index == 1) {
        shouldShowButton = true;
        selectedWidget = const CalendarView();
      } else if (index == 2) {
        shouldShowButton = false;
        selectedWidget = const ChatPage();
      } else if (index == 3) {
        shouldShowButton = true;
        selectedWidget = _profile();
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    for (int i = 0; i < _controllers.length; i++) {
      if (i == index) {
        _controllers[i].reset();
        _controllers[i].forward();
      } else {
        _controllers[i].reset();
      }
    }
  }

  Widget _main() {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
          child: const Center(
            child: Text(
              'Make your plan, and stick to it!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: const Text(
                    'Your Health Plan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildPlanItem('Bed Time', plan['bed_time']),
                _buildPlanItem('Breakfast Time', plan['breakfast_time']),
                _buildPlanItem('Dinner Time', plan['dinner_time']),
                _buildPlanItem(
                    'Exercise Amount', '${plan['exercise_amount']} min'),
                _buildPlanItem('Lunch Time', plan['lunch_time']),
                _buildPlanItem('Plan Date', plan['plan_date']),
                _buildPlanItem('Start Weight', '${plan['start_weight']} kg'),
                _buildPlanItem('Wake Up Time', plan['wake_up_time']),
                _buildPlanItem('Water Intake', '${plan['water']} ml'),
                _buildPlanItem('Current Weight', '${plan['weight']} kg'),
              ],
            ),
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Health Score',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ViewAllPage()),
                      );
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              SizedBox(
                width: 150,
                height: 150,
                child: Center(
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: ThreeQuarterCircularProgressPainter(
                          progress: scores["total_score"].toInt() / 100,
                          backgroundColor: Colors.white,
                          progressColor: getGradientColor(
                              scores["total_score"].toInt(),
                              0,
                              100,
                              Colors.red,
                              Colors.green),
                          strokeWidth: 10.0,
                          fontSize: 24.0,
                        ),
                        size: const Size.square(100),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanItem(String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profile() {
    return Center(
        child: ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries3.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          width: 200.0,
          height: 120.0,
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
          child: GestureDetector(
            onTap: () async {
              if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PlanPage()),
                );
              }
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              }
              if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AchievementsPage()),
                );
              }
              if (index == 3) {
                Navigator.pushReplacementNamed(context, '/');
                await storage.write(key: 'cookie', value: '');
              }
            },
            child: Center(
              child: Text(
                ' ${entries3[index]}',
                textScaleFactor: 2,
                style: TextStyle(
                  color: index == 3 ? Colors.red : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    ));
  }

  Widget _buildBottomNavItem(IconData iconData, int index) {
    bool isSelected = index == _selectedIndex;
    return GestureDetector(
      onTap: () {
        _onItemTapped(index);
      },
      child: AnimatedBuilder(
        animation: _controllers[index],
        builder: (BuildContext context, Widget? child) {
          double scale = isSelected ? 1.2 : 1.0;
          return Transform.scale(
            scale: scale,
            child: IconButton(
              icon: Icon(iconData),
              color: isSelected ? Colors.green : Colors.grey,
              onPressed: () {
                _onNavItemTapped(index);
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RecFit System'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/main.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: selectedWidget,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: shouldShowButton
          ? FloatingActionButton(
              backgroundColor: Colors.green,
              elevation: 8.0,
              child: const Icon(Icons.add),
              onPressed: () {
                showModalBottomSheet(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return const ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                      child: BottomSheetWidget(),
                    );
                  },
                );
              })
          : null,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomNavItem(Icons.home, 0),
            _buildBottomNavItem(Icons.calendar_month, 1),
            const SizedBox(width: 30.0),
            _buildBottomNavItem(Icons.search, 2),
            _buildBottomNavItem(Icons.account_circle, 3),
          ],
        ),
      ),
    );
  }
}
