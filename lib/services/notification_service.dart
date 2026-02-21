import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      tz.initializeTimeZones();
    } catch (_) {}

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    await _plugin.initialize(const InitializationSettings(android: android, iOS: iOS),
        onDidReceiveNotificationResponse: (response) {
      // handle tap / action payloads here (app will open)
    });
  }

  Future<void> showNotification({required int id, required String title, required String body, String? payload}) async {
    const androidDetails = AndroidNotificationDetails('doses', 'Doses', channelDescription: 'Dose reminders', importance: Importance.max, priority: Priority.high);
    const iosDetails = DarwinNotificationDetails();
    await _plugin.show(id, title, body, const NotificationDetails(android: androidDetails, iOS: iosDetails), payload: payload);
  }

  Future<void> scheduleNotification({required int id, required String title, required String body, required DateTime scheduledDate}) async {
    final androidDetails = AndroidNotificationDetails('doses', 'Doses', channelDescription: 'Dose reminders', importance: Importance.max, priority: Priority.high);
    final iosDetails = DarwinNotificationDetails();
    await _plugin.zonedSchedule(id, title, body, tz.TZDateTime.from(scheduledDate, tz.local), NotificationDetails(android: androidDetails, iOS: iosDetails), androidAllowWhileIdle: true, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, matchDateTimeComponents: DateTimeComponents.time);
  }
}
