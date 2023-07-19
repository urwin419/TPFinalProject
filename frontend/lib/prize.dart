import 'request.dart';
import 'package:flutter/material.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  AchievementsPageState createState() => AchievementsPageState();
}

class AchievementsPageState extends State<AchievementsPage> {
  Map<String, dynamic> isPrizes = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getAchievements();
  }

  void getAchievements() async {
    isPrizes = await fetchPrizes();
    setState(() {
      isLoading = false;
    });
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
            title: const Text('Prizes'),
            backgroundColor: Colors.green,
          ),
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      AchievementItem(
                        name: 'Bronze',
                        image: 'assets/images/prize/1.png',
                        description:
                            'The first week\'s health score reached 80 points.',
                        isAchieved:
                            isPrizes["health score achievement"]["Bronze"] == 1,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      AchievementItem(
                        name: 'Silver',
                        image: 'assets/images/prize/2.png',
                        description:
                            'Reaching a health score of 80 for 2 consecutive weeks.',
                        isAchieved:
                            isPrizes["health score achievement"]["Silver"] == 1,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      AchievementItem(
                        name: 'Gold',
                        image: 'assets/images/prize/3.png',
                        description:
                            'Reaching a health score of 80 for 3 consecutive weeks.',
                        isAchieved:
                            isPrizes["health score achievement"]["Gold"] == 1,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      AchievementItem(
                        name: 'Crown',
                        image: 'assets/images/prize/4.png',
                        description:
                            'Reaching a health score of 80 for 4 consecutive weeks.',
                        isAchieved:
                            isPrizes["health score achievement"]["Crown"] == 1,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      AchievementItem(
                        name: 'Best Challenger',
                        image: 'assets/images/prize/5.png',
                        description:
                            'Reaching a health score of 80 for 6 consecutive weeks.',
                        isAchieved: isPrizes["health score achievement"]
                                ["Challenger "] ==
                            1,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      AchievementItem(
                        name: 'Initial Entry',
                        image: 'assets/images/prize/6.png',
                        description:
                            'Up to 150 minutes during the first week of exercise(0/150h).',
                        isAchieved: isPrizes["exercise achievement"]
                                ["Initial entry"] ==
                            1,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      AchievementItem(
                        name: 'Heat crusher',
                        image: 'assets/images/prize/7.png',
                        description:
                            'Up to 150 minutes during the second consecutive week of exercise (0/150h).',
                        isAchieved: isPrizes["exercise achievement"]
                                ["Heat crusher"] ==
                            1,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      AchievementItem(
                        name: 'Fitness expert',
                        image: 'assets/images/prize/8.png',
                        description:
                            'Up to 150 minutes during the fourth consecutive week of exercise (0/150h).',
                        isAchieved: isPrizes["exercise achievement"]
                                ["Fitness expert"] ==
                            1,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      AchievementItem(
                        name: 'Water droplets',
                        image: 'assets/images/prize/9.png',
                        description:
                            'Up to 1500ML of drinking water for 3 consecutive days.',
                        isAchieved: isPrizes["water achievement"]
                                ["Water droplets"] ==
                            1,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      AchievementItem(
                        name: 'Water Flower',
                        image: 'assets/images/prize/10.png',
                        description:
                            'Up to 1500ML of drinking water for 3 consecutive days.',
                        isAchieved:
                            isPrizes["water achievement"]["Water flower"] == 1,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      AchievementItem(
                        name: 'Undersea starry sky',
                        image: 'assets/images/prize/11.png',
                        description:
                            'Up to 1500ML of drinking water for 7 consecutive days.',
                        isAchieved: isPrizes["water achievement"]
                                ["Undersea starry sky"] ==
                            1,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      AchievementItem(
                        name: 'Good figure achievement',
                        image: 'assets/images/prize/12.png',
                        description: 'Target weight achieved on the first day.',
                        isAchieved: isPrizes["weight achievement"]
                                ["Good figure achievement"] ==
                            1,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      AchievementItem(
                        name: 'Self-discipline',
                        image: 'assets/images/prize/13.png',
                        description:
                            'Maintain target weight for 3 consecutive days',
                        isAchieved: isPrizes["weight achievement"]
                                ["Self-discipline"] ==
                            1,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      AchievementItem(
                        name: 'Master of Figure Management',
                        image: 'assets/images/prize/14.png',
                        description:
                            'Maintain target weight for 7 consecutive days.',
                        isAchieved: isPrizes["weight achievement"]
                                ["Master of Figure Management"] ==
                            1,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      AchievementItem(
                        name: 'Moonlight',
                        image: 'assets/images/prize/15.png',
                        description: 'Meet 7 hours of sleep on the first day.',
                        isAchieved:
                            isPrizes["sleep achievement"]["Moonlight"] == 1,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      AchievementItem(
                        name: 'Moon Bay',
                        image: 'assets/images/prize/16.png',
                        description:
                            'Sleep for 7 hours for 3 consecutive days.',
                        isAchieved:
                            isPrizes["sleep achievement"]["Moon Bay"] == 1,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      AchievementItem(
                        name: 'Accompanied by the moon',
                        image: 'assets/images/prize/17.png',
                        description:
                            'Sleep for 7 hours for 7 consecutive days.',
                        isAchieved: isPrizes["sleep achievement"]
                                ["Accompanied by the moon"] ==
                            1,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      AchievementItem(
                        name: 'Regular diet',
                        image: 'assets/images/prize/18.png',
                        description: 'First Day Regular Diet Record.',
                        isAchieved:
                            isPrizes["meal achievement"]["Regular diet"] == 1,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      AchievementItem(
                        name: 'Healthy Dietitian',
                        image: 'assets/images/prize/19.png',
                        description: 'Regular diet for 3 consecutive days.',
                        isAchieved: isPrizes["meal achievement"]
                                ["Healthy Dietitian"] ==
                            1,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      AchievementItem(
                        name: 'Master of Diet Management',
                        image: 'assets/images/prize/20.png',
                        description: 'Regular diet for 7 consecutive days.',
                        isAchieved: isPrizes["meal achievement"]
                                ["Master of Diet Manager"] ==
                            1,
                      ),
                    ],
                  ),
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

class AchievementItem extends StatelessWidget {
  final String name;
  final String image;
  final String description;
  final bool isAchieved;

  const AchievementItem({
    super.key,
    required this.name,
    required this.image,
    required this.description,
    required this.isAchieved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isAchieved ? Colors.green[700] : Colors.grey[400],
        borderRadius: BorderRadius.circular(15.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            image,
            width: 100,
            height: 100,
            color: isAchieved ? null : Colors.grey,
          ),
          const SizedBox(height: 8.0),
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (isAchieved)
            const Text(
              'Achieved',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
