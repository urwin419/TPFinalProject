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
import 'records.dart';
import 'profile.dart';
import 'request.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'plan.dart';
import 'view.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const MyApp());
const serverUrl = '16.162.26.133:5000';
Map<String, dynamic> latestRecord = {
  'body': {
    'BMI': 19.6,
    'date': '2023-07-07',
    'height': 175.0,
    'weight': 60.0,
  },
  'exercise': {
    'exercise_amount': 70,
    'exercise_time': 'Fri, 07 Jul 2023 18:10:22 GMT',
    'exercise_type': 'Running',
  },
  'meal': {
    'meal_content': 'lunch',
    'meal_date': '2023-07-05',
    'meal_time': '11:45:00',
  },
  'plan': {
    'bed_time': '23:00:00',
    'breakfast_time': '09:00:00',
    'dinner_time': '17:00:00',
    'exercise_amount': 150,
    'lunch_time': '11:00:00',
    'plan_date': '2023-07-05',
    'wake_up_time': '08:00:00',
    'water': 2.0,
    'weight': 60.0,
  },
  'sleep': {
    'bed_time': 'Sat, 08 Jul 2023 22:40:00 GMT',
    'sleep_date': '2023-07-09',
    'wake_up_time': 'Sun, 09 Jul 2023 08:00:00 GMT',
  },
  'water': {
    'drinking_time': 'Fri, 07 Jul 2023 18:17:29 GMT',
    'drinking_volume': 200,
  },
};
Map<String, dynamic> plan = {
  "bed_time": "23:00:00",
  "breakfast_time": "08:00:00",
  "dinner_time": "18:00:00",
  "exercise_amount": 150,
  "lunch_time": "12:00:00",
  "plan_date": "2023-07-09",
  "start_weight": 80.0,
  "wake_up_time": "08:00:00",
  "water": 2000.0,
  "weight": 60.0
};
Map<String, dynamic> scores = {
  "bmi": 100,
  "exercise": 46.666666666666664,
  "meal": 0.0,
  "sleep": 12.54724111866969,
  "total_score": 37.55706727135299,
  "water": 28.571428571428573,
  "week_start": "2023-07-03"
};
var scoreweek = "2023-07-03";
var cookie = '';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String _title = 'Our App';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const MainPage(
              initialWidget: 'A',
            ),
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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController =
      TextEditingController(text: 'user1@gmail.com');
  final TextEditingController _passwordController =
      TextEditingController(text: 'password');
  bool _isLoading = false;

  void _submit() async {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      setState(() {
        _isLoading = true;
      });
      Map<String, dynamic> data = {
        'email': _emailController.text,
        'password': _passwordController.text
      };
      String body = json.encode(data);
      try {
        var response = await http.post(Uri.http(serverUrl, '/auth/login'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Connection': 'keep-alive'
            },
            body: body);
        setState(() {
          _isLoading = false;
        });
        if (kDebugMode) {
          print(response.statusCode);
        }
        if (response.statusCode == 200) {
          if (response.body == "Successfully login!") {
            var header = response.headers['set-cookie'];
            var cookies = header?.split(';')[0];
            cookie = cookies!;
            await fetchLatestRecord(context);
            await fetchPlan(context);
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            showAutoHideAlertDialog(context,
                ["Authentication failed", "Incorrect username or password"]);
          }
        } else {
          showAutoHideAlertDialog(
              context, ["Authentication failed", "Server unavailable now"]);
        }
      } catch (e) {
        showAutoHideAlertDialog(context, ["Failed", "Server unavailable now"]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Login',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/1.png"),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(64.0),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : _buildLoginForm(),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
        key: _formKey,
        child: Stack(children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: Form(
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'EMAIL',
                        labelStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.0,
                          ),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'EMAIL IS REQUIRED' : null,
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: Form(
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'PASSWORD',
                        labelStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.0,
                          ),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) =>
                          value!.isEmpty ? 'PASSWORD IS REQUIRED' : null,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  onPressed: _submit,
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                    child: Text(
                      'LOG IN',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('REGISTER'),
                ),
              ],
            ),
          )
        ]));
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController _emailController =
      TextEditingController(text: 'hzj20010425@163.com');
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  bool _isEmailValid = true;
  bool _isCoolingDown = false;
  int _coolDownTime = 60;
  Timer? _timer;
  void _validateEmail(String email) {
    bool isValid = EmailValidator.validate(email);
    setState(() {
      _isEmailValid = isValid;
    });
  }

  void startCoolDown() {
    setState(() {
      _isCoolingDown = true;
      _coolDownTime = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _coolDownTime -= 1;
      });

      if (_coolDownTime <= 0) {
        _timer?.cancel();
        setState(() {
          _isCoolingDown = false;
        });
      }
    });
  }

  void sendVerificationCode() async {
    if (_emailController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('HINT'),
          content: const Text('EMAIL IS EMPTY'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      try {
        Map<String, String> data = {
          'email': _emailController.text,
        };
        String body = json.encode(data);
        var response = await http.post(
          Uri.http(serverUrl, '/auth/captcha/get'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: body,
        );
        if (response.statusCode == 200) {
          startCoolDown();
        } else {
          showAutoHideAlertDialog(context, [
            "CAPTCHA SENDING FAILED",
            "Server unavailable now",
          ]);
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('FAILED'),
            content: const Text('CAPTCHA SENDING FAILED", "PLEASE TRY AGAIN'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('CONFIRM'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  void _submit() async {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      setState(() {
        _isLoading = true;
      });

      // Password validation
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _isLoading = false;
        });
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Passwords do not match.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      } else if (_passwordController.text.length < 8) {
        setState(() {
          _isLoading = false;
        });
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text(
                  'Password is too weak. Passwords must be at least 8 characters long.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }

      Map<String, dynamic> data = {
        'email': _emailController.text,
        'username': _usernameController.text,
        'password': _passwordController.text,
        "password_confirmed": _confirmPasswordController.text,
        'captcha': _verificationCodeController.text
      };

      String body = json.encode(data);

      var response = await http.post(
        Uri.http(serverUrl, '/auth/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        if (response.body == "Successfully register!") {
          Navigator.pushReplacementNamed(context, '/');
        } else if (response.body == "Email has been registered!") {
          showAutoHideAlertDialog(
              context, ["Registration failed", "Email has been registered!"]);
        } else {
          showAutoHideAlertDialog(
              context, ["Registration failed", "Invalid username or password"]);
        }
      } else {
        showAutoHideAlertDialog(
            context, ["Authentication failed", "Server unavailable now"]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Register',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/1.png"),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(64.0),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : _buildRegisterForm(),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
        key: _formKey,
        child: Stack(children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'EMAIL',
                    errorText: _isEmailValid ? null : 'EMAIL NOT VALID',
                    labelStyle: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Username is required' : null,
                  onChanged: _validateEmail,
                ),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'USERNAME',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Username is required' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'PASSWORD',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a password.';
                    } else if (value.length < 8) {
                      return 'Password is too weak. Passwords must be at least 8 characters long.';
                    } else if (value == _usernameController.text) {
                      return 'Password cannot be the same as username.';
                    } else if (value != _confirmPasswordController.text) {
                      return 'Passwords do not match.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'COMFIRM PASSWORD',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please confirm your password.';
                    } else if (value != _passwordController.text) {
                      return 'Passwords do not match.';
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _verificationCodeController,
                        decoration: const InputDecoration(
                          labelText: 'CAPTCHA',
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Captcha is required' : null,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isCoolingDown ? null : sendVerificationCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(_isCoolingDown
                          ? 'COOLING($_coolDownTime)'
                          : 'SEND CAPTCHA'),
                    ),
                  ],
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: _submit,
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Text(
                      'REGISTER',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ]));
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.initialWidget});
  final String initialWidget;
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _answer = '';
  bool _isSubmitting = false;
  final TextEditingController _questionController = TextEditingController();
  int _selectedIndex = 0;
  late Widget selectedWidget;
  final List<String> _images = [
    'assets/images/meal.jpg',
    'assets/images/water.jpg',
    'assets/images/weight.jpg',
    'assets/images/sleep.jpg',
    'assets/images/exe.jpg',
  ];
  List<dynamic> _searchHistory = [
    {
      "answer": "Ask your first question!",
      "qa_time": "2023-07-09T00:00:00",
      "question": "COME!"
    },
    {
      "answer": "Ask your first question!",
      "qa_time": "2023-07-09T00:00:00",
      "question": "COME!"
    },
    {
      "answer": "Ask your first question!",
      "qa_time": "2023-07-09T00:00:00",
      "question": "COME!"
    }
  ];
  final List<String> entries3 = <String>['Plans', 'Profile', 'Logout'];
  List records = [];
  int _power = 0;
  @override
  void initState() {
    super.initState();
    getHistory();
    if (widget.initialWidget == 'A') {
      selectedWidget = _record();
    } else if (widget.initialWidget == 'B') {
      selectedWidget = _past();
    } else if (widget.initialWidget == 'C') {
      selectedWidget = _assistant();
    } else if (widget.initialWidget == 'D') {
      selectedWidget = _profile();
    }
  }

  void fetchAnswer(question) async {
    String formattedTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    var url = Uri.http(serverUrl, '/query/NLP_QA');
    Map<String, dynamic> data = {
      "qa_time": formattedTime,
      "question": question
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
        String answer = json.decode(response.body)['answer'];
        setState(() {
          _answer = answer;
        });
        _showAnswerDialog();
      } else {
        throw Exception('Unexpected error occured!');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('FAILED'),
            content: const Text('Request Failed'),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showAnswerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Here is your answer!'),
          content: TypewriterText(text: _answer),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                _questionController.clear();
                Navigator.of(context).pop();
                setState(() {
                  getHistory();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void getHistory() async {
    _searchHistory = await fetchQAHistory();
  }

  void _incrementNumber() {
    setState(() {
      _power++;
    });
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 0) {
        selectedWidget = _record();
      } else if (index == 1) {
        fetchScores(context);
        selectedWidget = _past();
      } else if (index == 2) {
        selectedWidget = _assistant();
      } else if (index == 3) {
        selectedWidget = _profile();
      }
    });
  }

  Widget _record() {
    return GridView.count(
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
        _buildButton(_power.toString(), 'assets/images/p.png', 'p'),
      ],
    );
  }

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
            case 'p':
              _incrementNumber;
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

  String _convertTime(inputDateStr) {
    DateFormat inputFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz');

    DateTime inputDate = inputFormat.parse(inputDateStr);

    DateFormat outputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    String outputDateStr = outputFormat.format(inputDate);

    return outputDateStr;
  }

  Widget _past() {
    return ListView(
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
            prefix:
                '${latestRecord['meal']['meal_date']} ${latestRecord['meal']['meal_time']}',
            value: '\nYou had ${latestRecord['meal']['meal_content']}',
            score: scores["meal"].toInt().toString()),
        _buildRecordModule(
            label: 'Exercise',
            type: 'exercise',
            prefix: _convertTime(latestRecord['exercise']['exercise_time']),
            value:
                '\n${latestRecord['exercise']['exercise_type']} for ${latestRecord['exercise']['exercise_amount']} mins',
            score: scores["exercise"].toInt().toString()),
        _buildRecordModule(
            label: 'Water',
            type: 'water',
            prefix: _convertTime(latestRecord['water']['drinking_time']),
            value: '${latestRecord['water']['drinking_volume']} ml',
            score: scores["water"].toInt().toString()),
        _buildRecordModule(
            label: 'Sleep',
            type: 'sleep',
            prefix: 'Sleep',
            value:
                'from ${_convertTime(latestRecord['sleep']['bed_time'])} \nto ${_convertTime(latestRecord['sleep']['wake_up_time'])}',
            score: scores["sleep"].toInt().toString()),
      ],
    );
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
                  records = await fetchRecord(type);
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

  Color getGradientColor(
      int value, int minValue, int maxValue, Color startColor, Color endColor) {
    value = value.clamp(minValue, maxValue);
    double ratio = (value - minValue) / (maxValue - minValue);
    int r = (startColor.red + (endColor.red - startColor.red) * ratio).toInt();
    int g = (startColor.green + (endColor.green - startColor.green) * ratio)
        .toInt();
    int b =
        (startColor.blue + (endColor.blue - startColor.blue) * ratio).toInt();
    Color gradientColor = Color.fromARGB(255, r, g, b);
    return gradientColor;
  }

  void _showQuestionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Please enter your question.'),
          content: TextField(
            controller: _questionController,
            decoration: const InputDecoration(hintText: 'Question'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                _questionController.clear();
                Navigator.of(context).pop();
                setState(() {
                  getHistory();
                });
              },
            ),
            Visibility(
              visible: !_isSubmitting,
              child: TextButton(
                child: const Text('Submit'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _submitQuestion();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _submitQuestion() {
    String question = _questionController.text.trim();

    if (question.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Warning'),
            content: const Text('Question cannot be empty!'),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    fetchAnswer(question);
  }

  void _showSearchResult(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_searchHistory[index]['question']),
        content: Text(_searchHistory[index]['answer']),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  Widget _assistant() {
    return Stack(children: [
      Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          const SizedBox(
              width: 400,
              height: 100,
              child: Center(
                  child: Card(
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Your AI Assistant',
                          style: TextStyle(
                            fontFamily: 'Comic Neue',
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )))),
          const SizedBox(
            height: 16,
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              child: ListView.builder(
                itemCount: _searchHistory.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = _searchHistory[index]['question'];
                  return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          _showSearchResult(index);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ));
                },
              ),
            ),
          )
        ],
      ),
      Positioned(
        right: 16,
        bottom: 16,
        child: FloatingActionButton(
          onPressed: () {
            _showQuestionDialog();
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.search),
        ),
      ),
    ]);
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
            onTap: () {
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
                Navigator.pushReplacementNamed(context, '/');
                cookie = "";
              }
            },
            child: Center(
              child: Text(
                ' ${entries3[index]}',
                textScaleFactor: 2,
                style: TextStyle(
                  color: index == 2 ? Colors.red : Colors.black,
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
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.amber,
        backgroundColor: Colors.black,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.subject),
            backgroundColor: Colors.green,
            label: 'Now',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            backgroundColor: Colors.green,
            label: 'Past',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            backgroundColor: Colors.green,
            label: 'Assistant',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            backgroundColor: Colors.green,
            label: 'Me',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final Duration duration;

  const TypewriterText(
      {super.key,
      required this.text,
      this.duration = const Duration(milliseconds: 100)});

  @override
  _TypewriterTextState createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(widget.duration, (Timer timer) {
      setState(() {
        _index++;
      });
      if (_index >= widget.text.length) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String displayText = widget.text.substring(0, _index);

    return Text(displayText);
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
