// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  bool healthRating = false;
  double currentHeight = latestRecord['body']['height'];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _submitData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    String formattedDate = DateFormat('yyyy-M-d').format(DateTime.now());
    Map<String, dynamic> data = {
      "date": formattedDate,
      "height": currentHeight
    };
    String body = json.encode(data);
    final response = await http.post(Uri.parse('$serverUrl/record/body'),
        headers: {
          'cookie': cookie,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body);
    if (response.statusCode == 200) {
      return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: const Text('You just have your Height recorded!'),
          actions: <TextButton>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
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

  void _submitPreference() async {
    Map<String, dynamic> data = {"prefer_personal": healthRating};
    String body = json.encode(data);
    final response = await http.post(Uri.parse('$serverUrl/auth/scoring/update_preference'),
        headers: {
          'cookie': cookie,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body);
    if (response.statusCode == 200) {
      return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: const Text('You have changed your Scoring Preference!'),
          actions: <TextButton>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile Page'),
          backgroundColor: Colors.green,
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/profile.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                  opacity: 0.8,
                  child: Card(
                    elevation: 2.0,
                    child: ListTile(
                      title: const Text(
                        'Scoring Preferrence',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Switch(
                        value: healthRating,
                        onChanged: (newValue) {
                          setState(() {
                            healthRating = newValue;
                          });
                          _submitPreference();
                        },
                      ),
                      subtitle: const Text('Set the way we score you health.'),
                    ),
                  )),
              Opacity(
                  opacity: 0.8,
                  child: Card(
                      elevation: 2.0,
                      child: ListTile(
                          title: const Text(
                            'Height(cm)',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text('$currentHeight'),
                          subtitle: const Text('Set your height.'),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    title: const Text('Height(cm)'),
                                    content: SizedBox(
                                        height: 75,
                                        child: SingleChildScrollView(
                                            child: Form(
                                          key: _formKey,
                                          child: Column(
                                            children: [
                                              TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Please enter your exercise duration';
                                                  }
                                                  return null;
                                                },
                                                onChanged: (value) {
                                                  setState(() {
                                                    if (value.isEmpty) {
                                                      currentHeight = 0.0;
                                                    } else {
                                                      currentHeight =
                                                          double.parse(value);
                                                    }
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ))),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(dialogContext);
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: _submitData,
                                        child: const Text('Confirm'),
                                      ),
                                    ],
                                  );
                                });
                          }))),
            ],
          ),
        ));
  }
}
