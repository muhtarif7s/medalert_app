import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../repositories/history_repository.dart';
import '../models/history_entry.dart';
import '../repositories/local_db.dart';

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
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: iOS),
      onDidReceiveNotificationResponse: (response) async {
        try {
          final actionId = response.actionId; // Android action id
          final payload = response.payload;
          int? medId;
          String? timeStr;
          if (payload != null) {
            final map = jsonDecode(payload) as Map<String, dynamic>;
            medId = map['medicineId'] as int?;
            timeStr = map['time'] as String?;
          }

          String? action;
          if (actionId != null && actionId.isNotEmpty) {
            action = actionId; // e.g. 'mark_taken', 'remind'
          } else if (payload != null) {
            final map = jsonDecode(payload) as Map<String, dynamic>;
            action = map['action'] as String?;
          }

          if (action == null || medId == null) return;

          if (action == 'mark_taken' || action == 'taken') {
            final time = timeStr != null ? DateTime.tryParse(timeStr) ?? DateTime.now() : DateTime.now();
            await HistoryRepository.instance.insert(HistoryEntry(medicineId: medId, time: time, status: 'taken'));
            final db = LocalDatabase.instance.db;
            final rows = await db.query('medicines', where: 'id = ?', whereArgs: [medId]);
            if (rows.isNotEmpty) {
              final current = (rows.first['remainingQuantity'] ?? 0) as int;
              final updated = current > 0 ? current - 1 : 0;
              await db.update('medicines', {'remainingQuantity': updated}, where: 'id = ?', whereArgs: [medId]);
            }
          } else if (action == 'remind') {
            final next = DateTime.now().add(const Duration(minutes: 10));
            final payload2 = jsonEncode({'action': 'remind', 'medicineId': medId, 'time': next.toIso8601String()});
            final nid = medId * 1000 + next.millisecondsSinceEpoch.remainder(1000);
            await scheduleNotification(id: nid, title: 'Reminder', body: 'Reminder to take your medicine', scheduledDate: next, payload: payload2);
          }
        } catch (_) {}
      },
    );
  }

  Future<void> showNotification({required int id, required String title, required String body, String? payload}) async {
    final androidDetails = AndroidNotificationDetails(
      'doses',
      'Doses',
      channelDescription: 'Dose reminders',
      importance: Importance.max,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction('mark_taken', 'Mark taken'),
        const AndroidNotificationAction('remind', 'Remind me'),
      ],
    );
    const iosDetails = DarwinNotificationDetails(categoryIdentifier: 'DOSE_CATEGORY');
    await _plugin.show(id, title, body, NotificationDetails(android: androidDetails, iOS: iosDetails), payload: payload);
  }

  Future<void> scheduleNotification({required int id, required String title, required String body, required DateTime scheduledDate, String? payload}) async {
    final androidDetails = AndroidNotificationDetails(
      'doses',
      'Doses',
      channelDescription: 'Dose reminders',
      importance: Importance.max,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction('mark_taken', 'Mark taken'),
        const AndroidNotificationAction('remind', 'Remind me'),
      ],
    );
    const iosDetails = DarwinNotificationDetails(categoryIdentifier: 'DOSE_CATEGORY');

    // Use platform scheduling so notifications persist across restarts.
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }
}
