import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:math';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(settings);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showNotification() async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'levelup_channel',
      'LevelUp Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
    NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'LevelUp AI 🚀',
      'Time to complete your tasks!',
      details,
    );
  }

  static List<String> motivationalMessages = [
    "Complete today's tasks and keep your streak alive 🔥",
    "Small progress every day leads to big success 🚀",
    "Stay consistent. Your future self will thank you 💪",
    "Your goals are waiting for you 👑",
  ];

  //get random message
  static String getRandomMessage() {
    final random = Random();

    return motivationalMessages[
    random.nextInt(motivationalMessages.length)];
  }

  static Future<void> scheduleNotification() async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
    NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'LevelUp Reminder 🚀',
      'Complete your goals today!',
      tz.TZDateTime.now(tz.local).add(
        const Duration(seconds: 10),
      ),
      details,
      androidScheduleMode:
      AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
    print("Notification scheduled");
  }

  // daily reminder message
  static Future<void> scheduleDailyReminder() async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminder',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
    NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      2,
      'LevelUp AI 🚀',
      getRandomMessage(),
      _nextInstanceOfNineAM(),
      details,
      androidScheduleMode:
      AndroidScheduleMode.inexactAllowWhileIdle,

      matchDateTimeComponents:
      DateTimeComponents.time,

      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  //Time function
  static tz.TZDateTime _nextInstanceOfNineAM() {
    final tz.TZDateTime now =
    tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate =
    tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      9,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate =
          scheduledDate.add(
            const Duration(days: 1),
          );
    }

    return scheduledDate;
  }
}