import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:group_project/main.dart';
import 'package:group_project/other.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void scheduleNotifications() async {
  bool notificationPref = await getNotificationPreference();
  if (notificationPref == true && plan != {}) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const androidInitializationSettings =
        AndroidInitializationSettings('app_icon');
    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    final now = DateTime.now();
    final today = now.toString().split(' ')[0];
    tz.initializeTimeZones();

    final breakfastTime =
        tz.TZDateTime.parse(tz.local, '$today ${plan['breakfast_time']}');
    final lunchTime =
        tz.TZDateTime.parse(tz.local, '$today ${plan['lunch_time']}');
    final dinnerTime =
        tz.TZDateTime.parse(tz.local, '$today ${plan['dinner_time']}');
    final bedtime = tz.TZDateTime.parse(tz.local, '$today ${plan['bed_time']}');
    final waketime =
        tz.TZDateTime.parse(tz.local, '$today ${plan['wake_up_time']}');

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Reminder',
        'Time to have dinner!',
        dinnerTime.add(const Duration(days: 1)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_id',
            'channel_name',
            channelDescription: 'channel_description',
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        1,
        'Reminder',
        'Time to have breakfast!',
        breakfastTime.add(const Duration(days: 1)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_id',
            'channel_name',
            channelDescription: 'channel_description',
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        2,
        'Reminder',
        'Time to have lunch!',
        lunchTime.add(const Duration(days: 1)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_id',
            'channel_name',
            channelDescription: 'channel_description',
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        3,
        'Reminder',
        'Time to go to sleep!',
        bedtime.add(const Duration(days: 1)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_id',
            'channel_name',
            channelDescription: 'channel_description',
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        4,
        'Reminder',
        'Time to wake up!',
        waketime.add(const Duration(days: 1)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_id',
            'channel_name',
            channelDescription: 'channel_description',
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }
}
