// ignore_for_file: use_build_context_synchronously

import 'package:group_project/login.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'other.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
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
          Uri.parse('$serverUrl/auth/captcha/get'),
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
        'email': _emailController.text.trim(),
        'username': _usernameController.text.trim(),
        'password': _passwordController.text.trim(),
        "password_confirmed": _confirmPasswordController.text.trim(),
        'captcha': _verificationCodeController.text.trim()
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
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
        automaticallyImplyLeading: false,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back),
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
