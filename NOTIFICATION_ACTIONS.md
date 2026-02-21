Notification actions and scheduling

This project uses `flutter_local_notifications` with timezone-aware scheduling and actionable notification buttons.

What was implemented

- Dart-side: `lib/services/notification_service.dart` uses `zonedSchedule` and attaches Android actions (`mark_taken`, `remind`) and an iOS category (`DOSE_CATEGORY`). The Dart callback `onDidReceiveNotificationResponse` parses the `actionId` and `payload` to mark doses taken, decrement inventory, or schedule a short reminder.

- Android: Added permissions to `android/app/src/main/AndroidManifest.xml`:
  - `android.permission.SCHEDULE_EXACT_ALARM`
  - `android.permission.RECEIVE_BOOT_COMPLETED`

- iOS: Registered UNNotificationCategory and actions in `ios/Runner/AppDelegate.swift` and set the notification center delegate.

Platform steps to verify and finalize

Android
- Build and run on a device/emulator. Android 12+ may require the user to grant the app permission to schedule exact alarms. The app will request runtime permission if needed; otherwise guide the user to Settings → Apps → Special app access → Exact alarms.
- Verify that scheduled notifications appear at the correct time and that notification buttons show. Tapping "Mark taken" should insert a history entry and decrement the medicine remaining quantity.

iOS
- Build and run on a device/simulator. iOS simulators support notifications via Xcode.
- Verify that the notification shows the category actions ("Mark taken", "Remind me"). Tapping them should trigger the app's notification response handler (when the app is in foreground/background) and behave like Android.

Notes & troubleshooting
- Action handling requires the app to call `NotificationService.init()` during startup (already performed in `lib/main.dart`).
- Background behavior and exact permission flows differ by OS version; test on real devices for accurate behavior.
- If actions do not appear on Android, ensure `flutter_local_notifications` is up-to-date and that the notification channel supports actions on your device.

If you want, I can also:
- Add a broadcast receiver to auto-reschedule any in-app scheduled reminders on boot (if you rely on your own scheduling fallback).
- Add a small integration test or sample flows demonstrating mark-taken via a triggered notification (requires a connected device/emulator).
