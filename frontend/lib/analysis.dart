import 'package:flutter/material.dart';

String generateSleepAnalysis(List<Map<String, dynamic>> sleepData) {
  int totalSleepDuration = 0;
  int averageSleepDuration = 0;

  for (final sleepEntry in sleepData) {
    final bedTime = DateTime.parse(sleepEntry['bed_time']);
    final wakeUpTime = sleepEntry['wake_up_time'] != null
        ? DateTime.parse(sleepEntry['wake_up_time'])
        : DateTime.parse("${sleepEntry['sleep_date']} 08:30:00");

    final sleepDuration = wakeUpTime.difference(bedTime);
    totalSleepDuration += sleepDuration.inMinutes;
  }

  if (sleepData.isNotEmpty) {
    averageSleepDuration = totalSleepDuration ~/ sleepData.length;
  }

  String sleepAnalysis = '';
  sleepAnalysis +=
      'Based on your sleep data, here is an analysis of your sleep:\n\n';
  sleepAnalysis +=
      'Total sleep duration: ${totalSleepDuration ~/ 60} hours ${totalSleepDuration.remainder(60)} minutes\n\n';
  sleepAnalysis +=
      'Average sleep duration: ${averageSleepDuration ~/ 60} hours ${averageSleepDuration.remainder(60)} minutes\n\n';

  sleepAnalysis +=
      'Based on your sleep situation, we have the following suggestions for you:\n\n';

  if (averageSleepDuration < 6 * 60) {
    sleepAnalysis +=
        'Your sleep duration is relatively short. We recommend aiming for 6-8 hours of sleep per night to ensure sufficient rest.\n\n';
  } else if (averageSleepDuration > 9 * 60) {
    sleepAnalysis +=
        'Your sleep duration is relatively long. Please check if you might be oversleeping and consider adjusting your sleep time.\n\n';
  }

  if (averageSleepDuration >= 7 * 60) {
    sleepAnalysis += 'Your sleep quality is good. Keep it up!\n\n';
  } else if (averageSleepDuration >= 6 * 60) {
    sleepAnalysis +=
        'Your sleep quality is average. We recommend creating a comfortable sleep environment to ensure undisturbed rest.\n\n';
  } else {
    sleepAnalysis +=
        'Your sleep quality is poor. We suggest improving your sleep habits, such as regular exercise and relaxation techniques.\n\n';
  }

  return sleepAnalysis;
}

String generateBodyAnalysis(List<Map<String, dynamic>> data) {
  double totalBMI = 0;
  for (var entry in data) {
    totalBMI += entry['BMI'];
  }
  double averageBMI = totalBMI / data.length;

  double maxBMI = double.minPositive;
  double minBMI = double.maxFinite;
  String maxDate = '';
  String minDate = '';
  for (var entry in data) {
    if (entry['BMI'] > maxBMI) {
      maxBMI = entry['BMI'];
      maxDate = entry['date'];
    }
    if (entry['BMI'] < minBMI) {
      minBMI = entry['BMI'];
      minDate = entry['date'];
    }
  }

  String healthEvaluation = '';
  String advice = '';
  if (averageBMI < 18.5) {
    healthEvaluation =
        'Your average BMI is $averageBMI, which falls into the underweight range. It is recommended that you increase your food intake and engage in regular exercise to reach a healthy weight level.';
    advice =
        'You may consult a nutritionist or doctor to obtain a proper diet plan and increase the intake of nutrients. Additionally, regular exercise helps to enhance physical fitness and overall health.';
  } else if (averageBMI < 24.9) {
    healthEvaluation =
        'Your average BMI is $averageBMI, which falls into the normal weight range. Keep up the good eating habits and exercise routines to maintain a healthy body.';
    advice =
        'Continue maintaining good eating habits, ensuring a balanced intake of various nutrients, and participate in regular physical exercises to maintain good health and enhance the quality of life.';
  } else if (averageBMI < 29.9) {
    healthEvaluation =
        'Your average BMI is $averageBMI, which falls into the overweight range. It is recommended that you control your diet and engage in physical exercises to reduce weight.';
    advice =
        'Pay attention to a healthy diet by reducing the intake of fats and sugars, and increasing the consumption of vegetables, fruits, and proteins. Regular participation in moderate aerobic exercises and strength training will help in fat reduction and body shaping.';
  } else {
    healthEvaluation =
        'Your average BMI is $averageBMI, which falls into the obesity range. It is strongly advised that you take immediate measures, including adjusting your diet and increasing physical exercises to lose weight.';
    advice =
        'We recommend seeking guidance from a professional nutritionist or doctor to develop an effective weight loss plan. Control your diet by reducing the intake of high-calorie and high-fat foods. Regular participation in aerobic exercises and strength training will assist in fat burning and metabolic improvement.';
  }

  String analysis = '''
    Recent BMI Data Analysis:
    - Average BMI Value: $averageBMI
    - Maximum BMI Value: $maxBMI (Date: $maxDate)
    - Minimum BMI Value: $minBMI (Date: $minDate)

    Health Evaluation: $healthEvaluation

    Health Advice: $advice
  ''';

  return analysis;
}

String generateMealAnalysis(List<Map<String, dynamic>> mealData) {
  String analysis = '';

  int totalDays = mealData.length;
  int shortBreakfastToLunch = 0;
  int longBreakfastToLunch = 0;
  int shortLunchToDinner = 0;
  int longLunchToDinner = 0;

  for (var data in mealData) {
    String? breakfastTime = data['breakfast_time'] ?? "08:00:00";
    String? lunchTime = data['lunch_time'] ?? "12:00:00";
    String? dinnerTime = data['dinner_time'] ?? "19:00:00";

    DateTime breakfast = DateTime.parse('2023-01-01 $breakfastTime');
    DateTime lunch = DateTime.parse('2023-01-01 $lunchTime');
    DateTime dinner = DateTime.parse('2023-01-01 $dinnerTime');

    Duration breakfastToLunch = lunch.difference(breakfast);
    Duration lunchToDinner = dinner.difference(lunch);

    if (breakfastToLunch.inHours < 4) {
      shortBreakfastToLunch++;
    } else if (breakfastToLunch.inHours > 6) {
      longBreakfastToLunch++;
    }

    if (lunchToDinner.inHours < 4) {
      shortLunchToDinner++;
    } else if (lunchToDinner.inHours > 6) {
      longLunchToDinner++;
    }
  }

  analysis += 'Overall Assessment:\n';

  if (shortBreakfastToLunch > totalDays / 2) {
    analysis +=
        'The time interval between breakfast and lunch is frequently too short. It is strongly recommended to extend the duration to maintain a more consistent energy supply.\n';
  } else if (longBreakfastToLunch > totalDays / 2) {
    analysis +=
        'The time interval between breakfast and lunch is frequently too long. It is recommended to shorten the duration to maintain a more stable energy supply.\n';
  } else {
    analysis +=
        'The time interval between breakfast and lunch is generally reasonable, which helps in balancing the energy supply.\n';
  }

  if (shortLunchToDinner > totalDays / 2) {
    analysis +=
        'The time interval between lunch and dinner is frequently too short. It is strongly recommended to extend the duration to promote proper digestion and ensure a good sleep.\n';
  } else if (longLunchToDinner > totalDays / 2) {
    analysis +=
        'The time interval between lunch and dinner is frequently too long. It is recommended to shorten the duration to maintain a more stable digestion and absorption.\n';
  } else {
    analysis +=
        'The time interval between lunch and dinner is generally reasonable, which helps in balancing digestion and absorption.\n';
  }

  return analysis;
}

String generateAdvice(double averageVolume) {
  String advice = '';

  if (averageVolume < 1000) {
    advice +=
        "Your average daily water intake is quite low. It is recommended to increase your water consumption and keep your body hydrated.\n";
  } else if (averageVolume < 2000) {
    advice +=
        "Your average daily water intake is still insufficient. It is recommended to increase your water consumption and drink more water.\n";
  } else if (averageVolume < 3000) {
    advice +=
        "Your average daily water intake is good. Keep up the good habit of staying hydrated.\n";
  } else {
    advice +=
        "Your average daily water intake is very good. Keep up the good habit of staying hydrated.\n";
  }

  advice +=
      "It is recommended to drink water regularly throughout the day to maintain a good water balance in your body.\n";
  advice +=
      "Consider setting reminders or alarms to remind yourself to drink enough water.\n";
  advice +=
      "Remember to replenish electrolytes in a timely manner. You can choose to drink sports drinks or consume foods high in sodium.\n";

  return advice;
}

String generateWaterAnalysis(List<Map<String, dynamic>> dataList) {
  Map<String, List<int>> volumeByDate = {};

  for (var data in dataList) {
    String drinkingDate = data['drinking_time'].split(' ')[0];
    int volume = data['drinking_volume'];

    if (volumeByDate.containsKey(drinkingDate)) {
      volumeByDate[drinkingDate]!.add(volume);
    } else {
      volumeByDate[drinkingDate] = [volume];
    }
  }

  String analysis = "Based on the provided data analysis:\n";

  double totalVolume = 0;
  volumeByDate.forEach((date, volumeList) {
    int totalVolumeForDate = volumeList.reduce((a, b) => a + b);
    totalVolume += totalVolumeForDate;
  });

  double averageVolume = totalVolume / volumeByDate.length;
  analysis +=
      "\nYour average daily drinking volume is ${averageVolume.toStringAsFixed(2)}ml\n";

  String advice = generateAdvice(averageVolume);
  analysis += "\nHere's your advice:\n$advice";

  return analysis;
}

List<String> calculateWeeklyAverageTime(
    List<Map<String, dynamic>> exerciseData) {
  int totalExerciseTimeWeek1 = 0;
  int totalExerciseTimeWeek2 = 0;
  int totalExerciseTimeWeek3 = 0;

  int exerciseCountWeek1 = 0;
  int exerciseCountWeek2 = 0;
  int exerciseCountWeek3 = 0;

  DateTime currentDate = DateTime.now();

  for (var exercise in exerciseData) {
    DateTime exerciseDateTime = DateTime.parse(exercise['exercise_time']);
    int exerciseAmount = exercise['exercise_amount'];

    int differenceInDays = currentDate.difference(exerciseDateTime).inDays;

    if (differenceInDays <= 7) {
      totalExerciseTimeWeek1 += exerciseAmount;
      exerciseCountWeek1++;
    } else if (differenceInDays <= 14) {
      totalExerciseTimeWeek2 += exerciseAmount;
      exerciseCountWeek2++;
    } else if (differenceInDays <= 21) {
      totalExerciseTimeWeek3 += exerciseAmount;
      exerciseCountWeek3++;
    }
  }

  double averageExerciseTimeWeek1 = (exerciseCountWeek1 != 0)
      ? totalExerciseTimeWeek1 / exerciseCountWeek1
      : 0;
  double averageExerciseTimeWeek2 = (exerciseCountWeek2 != 0)
      ? totalExerciseTimeWeek2 / exerciseCountWeek2
      : 0;
  double averageExerciseTimeWeek3 = (exerciseCountWeek3 != 0)
      ? totalExerciseTimeWeek3 / exerciseCountWeek3
      : 0;

  return [
    averageExerciseTimeWeek1.toStringAsFixed(0),
    averageExerciseTimeWeek2.toStringAsFixed(0),
    averageExerciseTimeWeek3.toStringAsFixed(0),
  ];
}

String generateExerciseAnalysis(List<Map<String, dynamic>> exerciseData) {
  List<String> weeklyAverageTimes = calculateWeeklyAverageTime(exerciseData);

  String analysisText = "Exercise Analysis:\n\n";
  String recommendationText = "Recommendations:\n\n";

  if (int.parse(weeklyAverageTimes[0]) >= 60 &&
      int.parse(weeklyAverageTimes[1]) >= 60 &&
      int.parse(weeklyAverageTimes[2]) >= 60) {
    analysisText +=
        "You have been consistently exercising for at least 60 minutes each week. Great job!\n";
    recommendationText +=
        "1. Keep up the good work and maintain your exercise routine.\n";
    recommendationText +=
        "2. Consider challenging yourself with more intense workouts or trying new activities to add variety.\n";
    recommendationText +=
        "3. Make sure to listen to your body and prioritize proper rest and recovery.\n";
  } else if (int.parse(weeklyAverageTimes[0]) < 60 &&
      int.parse(weeklyAverageTimes[1]) < 60 &&
      int.parse(weeklyAverageTimes[2]) < 60) {
    analysisText +=
        "Your exercise time is below the recommended 60 minutes per week.\n";
    recommendationText +=
        "1. Start by setting achievable exercise goals. Aim for at least 30 minutes of moderate-intensity exercise on most days of the week.\n";
    recommendationText +=
        "2. Make physical activity a priority in your daily routine. Find activities you enjoy and make them a part of your lifestyle.\n";
    recommendationText +=
        "3. Consider incorporating more active habits throughout the day, such as taking the stairs instead of the elevator or walking during breaks.\n";
  } else {
    analysisText += "Your exercise time varies across different weeks.\n";
    recommendationText +=
        "1. Try to establish a consistent exercise routine. Aim for at least 60 minutes of exercise per week, evenly distributed throughout the days.\n";
    recommendationText +=
        "2. Prioritize time management and schedule your workouts to ensure you are dedicating enough time to exercise.\n";
    recommendationText +=
        "3. Mix up your workout routines to prevent boredom and keep yourself motivated.\n";
    recommendationText +=
        "4. Don't forget to set realistic goals and track your progress to stay motivated.\n";
  }

  return "$analysisText\n$recommendationText";
}

class AnalysisDialog extends StatelessWidget {
  final String analysis;

  const AnalysisDialog({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Analysis'),
      content: SingleChildScrollView(
        child: Text(analysis),
      ),
      actions: [
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

void showAnalysisDialog(BuildContext context, String analysis) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AnalysisDialog(analysis: analysis);
    },
  );
}
