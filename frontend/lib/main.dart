// ignore_for_file: unused_import, library_private_types_in_public_api, use_build_context_synchronously, invalid_use_of_visible_for_testing_member, unused_field

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';
import 'package:http/http.dart' as http;
import 'records.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:group_project/plan.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const MyApp());
const serverUrl = '16.162.26.133:5000';
const List<String> meals = <String>["Breakfast", "Lunch", "Dinner"];
const List<String> exes = <String>["Jogging", "Crunches", "Push-ups"];
var cookie = '';
var isLoggedIn = false;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String _title = 'Our App';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      initialRoute: '/login',
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MyStatefulWidget(
              initialWidget: 'A',
            ),
        '/register': (context) => const RegisterPage(),
        '/plan': (context) => const PlanPage(),
      },
    );
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

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key, required this.initialWidget});
  final String initialWidget;
  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
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
      var response = await http.post(Uri.http(serverUrl, '/auth/login'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
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
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          cookie = cookies!;
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          showAutoHideAlertDialog(context,
              ["Authentication failed", "Incorrect username or password"]);
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
                  child: Expanded(
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
                  child: Expanded(
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

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  String selectedMeal = meals.first;
  String selectedexe = exes.first;
  int _selectedIndex = 0;
  late Widget selectedWidget;
  String _operation = 'record weight';
  String _searchText = '';
  final List<String> _images = [
    'assets/images/meal.jpg',
    'assets/images/water.jpg',
    'assets/images/weight.jpg',
    'assets/images/sleep.jpg',
    'assets/images/exe.jpg',
  ];
  final List<String> _searchHistory = [
    'Search history 1',
    'Search history 2',
    'Search history 3'
  ];
  final List<String> entries3 = <String>['Plans', 'Profile', 'Logout'];
  int healthScore = 75;
  final List<String> scores = ['15', '15', '15', '15', '15'];
  List<double> weightRecords = [70, 72.5, 69.8];
  double get latestWeight => weightRecords.isNotEmpty ? weightRecords.first : 0;
  List<String> dietRecords = [
    "Breakfast: Eggs and toast",
    "Lunch: Salad",
    "Dinner: Grilled chicken"
  ];
  List<String> exerciseRecords = ["Morning run", "Afternoon yoga"];
  List<int> waterRecords = [200, 300, 250];
  List<int> sleepRecords = [7, 6, 8];
  int _power = 0;
  @override
  void initState() {
    super.initState();
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

  void updateText(String text) {
    setState(() {
      _operation = text;
    });
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

  Widget _past() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHealthScoreModule(),
        _buildRecordModule(
            label: 'Weight',
            value: latestWeight.toString(),
            records: weightRecords.map((weight) => weight.toString()).toList(),
            score: scores[0]),
        _buildRecordModule(
            label: 'Diet',
            value: dietRecords.first,
            records: dietRecords,
            score: scores[1]),
        _buildRecordModule(
            label: 'Exercise',
            value: exerciseRecords.first,
            records: exerciseRecords,
            score: scores[2]),
        _buildRecordModule(
            label: 'Water',
            value: waterRecords.first.toString(),
            records: waterRecords.map((amount) => amount.toString()).toList(),
            score: scores[3]),
        _buildRecordModule(
            label: 'Sleep',
            value: sleepRecords.first.toString(),
            records: sleepRecords.map((hours) => '$hours hours').toList(),
            score: scores[4]),
      ],
    );
  }

  Widget _buildHealthScoreModule() {
    Color numberColor = healthScore >= 75 ? Colors.green : Colors.red;
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
              healthScore.toString(),
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
      required String value,
      required List<String> records,
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
                'Latest: $value',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                child: const Text('View all'),
                onPressed: () {},
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

  void _searchTextChanged(String newValue) {
    setState(() {
      _searchText = newValue;
    });
  }

  void _showSearchResult(String item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Search Result'),
        content: Text('You tapped on: $item'),
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: const Text(
            'Your AI Assistant',
            style: TextStyle(
              fontFamily: 'Comic Neue',
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            onChanged: _searchTextChanged,
            decoration: const InputDecoration(
              icon: Icon(Icons.search),
              hintText: 'Search',
              border: InputBorder.none,
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 15),
            child: ListView.builder(
              itemCount: _searchHistory.length,
              itemBuilder: (BuildContext context, int index) {
                final item = _searchHistory[index];
                return InkWell(
                  onTap: () {
                    _showSearchResult(item);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey)),
                    ),
                    child: Text(item),
                  ),
                );
              },
            ),
          ),
        ),
      ],
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
            onTap: () {
              if (index == 2) {
                Navigator.pushReplacementNamed(context, '/');
                cookie = "";
              }
              if (index == 0) {
                Navigator.pushReplacementNamed(context, '/plan');
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
        backgroundColor: Colors.greenAccent,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/login.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: selectedWidget,
          ),
        ],
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
        //selectedItemColor: Colors.amber[800],
        onTap: _onNavItemTapped,
      ),
    );
  }
}
