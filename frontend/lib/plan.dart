import 'package:flutter/material.dart';

import 'main.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  PlanPagestate createState() => PlanPagestate();
}

class PlanPagestate extends State<PlanPage> {
  List<bool> completeness = [false, false, false, false, false];
  var weight = 60;
  List<String> mealtime = ['8:30:00', '12:00:00', '18:00:00'];
  var exetime = 150;
  var water = 2;
  List<String> sleeptime = ['23:00:00', '8:00:00'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/login.png"),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(8.0),
        child: ListView(
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
                    title: const Text('weight Dialog'),
                    actions: [
                      ElevatedButton(
                        child: const Text('Cancel'),
                        onPressed: () {
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
                    title: const Text('Mealtime Dialog'),
                    actions: [
                      ElevatedButton(
                        child: const Text('Cancel'),
                        onPressed: () {
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
                    title: const Text('Exercise Dialog'),
                    actions: [
                      ElevatedButton(
                        child: const Text('Cancel'),
                        onPressed: () {
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
                    title: const Text('Water Dialog'),
                    actions: [
                      ElevatedButton(
                        child: const Text('Cancel'),
                        onPressed: () {
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
                    title: const Text('Sleep Dialog'),
                    actions: [
                      ElevatedButton(
                        child: const Text('Cancel'),
                        onPressed: () {
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
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const MyStatefulWidget(initialWidget: 'D'),
                  ),
                );
              },
            ),
            ElevatedButton(
              child: const Text('Comfirm'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const MyStatefulWidget(initialWidget: 'D'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
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
    return Expanded(
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
      ),
    );
  }
}
