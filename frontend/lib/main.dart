// ignore_for_file: unused_import, library_private_types_in_public_api, use_build_context_synchronously, invalid_use_of_visible_for_testing_member, unused_field

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:group_project/exerecord.dart';
import 'package:intl/intl.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';
import 'mealrecord.dart';
import 'weightrecord.dart';
import 'package:http/http.dart' as http;
import 'package:group_project/dialogs.dart';
import 'recview.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:group_project/plan.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

const serverUrl = '16.162.26.133:5000';
const List<String> meals = <String>["Breakfast", "Lunch", "Dinner"];
const List<String> exes = <String>["Jogging", "Crunches", "Push-ups"];
var cookie = '';
var isLoggedIn = false;
void main() => runApp(const MyApp());
/*Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp(const MyApp());
}*/

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String _title = 'Our App';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //home: isLoggedIn == false ? const LoginPage() : const MyStatefulWidget(),
      title: _title,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
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

  // 邮箱验证逻辑
  void _validateEmail(String email) {
    bool isValid = EmailValidator.validate(email);

    setState(() {
      _isEmailValid = isValid;
    });
  }

  bool _isCoolingDown = false;
  int _coolDownTime = 60;
  Timer? _timer;
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
              child: const Text('COMFIRM'),
            ),
          ],
        ),
      );
    } else {
      try {
        await Future.delayed(const Duration(seconds: 2));
        startCoolDown();
      } catch (e) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('FAILED'),
            content: const Text('CAPTCHA SENDING FAILED，PLEASE TRY AGAIN'),
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
  final List<String> entries1 = <String>['Weight', 'Meal', 'Exercise'];
  final List<String> entries2 = <String>[
    'weight records',
    'meal records',
    'exercise records'
  ];
  final List<String> entries3 = <String>['Plans', 'Profile', 'Logout'];
  int healthScore = 75; // 用户的健康评分
  List<double> weightRecords = [70, 72.5, 69.8]; // 体重记录
  double get latestWeight => weightRecords.isNotEmpty ? weightRecords.first : 0;
  List<String> dietRecords = [
    "Breakfast: Eggs and toast",
    "Lunch: Salad",
    "Dinner: Grilled chicken"
  ]; // 饮食记录
  List<String> exerciseRecords = ["Morning run", "Afternoon yoga"]; // 运动记录
  List<int> waterRecords = [200, 300, 250]; // 饮水记录
  List<int> sleepRecords = [7, 6, 8];
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
      padding:
          const EdgeInsets.fromLTRB(20, 40, 20, 40), // 设置上下各40，左右各20像素的空白边缘
      crossAxisSpacing: 20.0, // 列之间的空隙
      mainAxisSpacing: 20.0,
      crossAxisCount: 2, // 两列
      childAspectRatio: 1.0, // 宽高比为1:1
      children: <Widget>[
        _buildButton('MEAL', _images[0], 'meal'),
        _buildButton('WATER', _images[1], 'meal'),
        _buildButton('WEIGHT', _images[2], 'wei'),
        _buildButton('SLEEP', _images[3], 'wei'),
        _buildButton('EXERCISE', _images[4], 'exe'),
      ],
    );
  }

  Widget _buildButton(String title, String image, String w) {
    return Card(
      child: InkWell(
        onTap: () {
          switch (w) {
            case 'wei':
              weidialog(context);
              break;
            case 'meal':
              mealdialog(context, selectedMeal, meals);
              break;
            case 'exe':
              exedialog(context, selectedexe, exes);
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
        ),
        _buildRecordModule(
          label: 'Diet',
          value: dietRecords.first,
          records: dietRecords,
        ),
        _buildRecordModule(
          label: 'Exercise',
          value: exerciseRecords.first,
          records: exerciseRecords,
        ),
        _buildRecordModule(
          label: 'Water',
          value: waterRecords.first.toString(),
          records: waterRecords.map((amount) => amount.toString()).toList(),
        ),
        _buildRecordModule(
          label: 'Sleep',
          value: sleepRecords.first.toString(),
          records: sleepRecords.map((hours) => '$hours hours').toList(),
        ),
      ],
    );
  }

  Widget _buildHealthScoreModule() {
    Color numberColor = healthScore >= 75 ? Colors.green : Colors.red;
    return Card(
      child: ListTile(
        title: const Text(
          'Health Score',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Text(
          healthScore.toString(),
          style: TextStyle(
            color: numberColor,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildRecordModule(
      {required String label,
      required String value,
      required List<String> records}) {
    return Card(
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
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
      ),
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
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: const Text(
            'Your AI Assistant',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Search input
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
        // Search history
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
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
    return ListView.separated(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RecFit System'),
        backgroundColor: Colors.black,
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
        backgroundColor: Colors.blue,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.subject),
            backgroundColor: Colors.blue,
            label: 'Now',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            backgroundColor: Colors.blue,
            label: 'Past',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            backgroundColor: Colors.blue,
            label: 'Assistent',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            backgroundColor: Colors.blue,
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
