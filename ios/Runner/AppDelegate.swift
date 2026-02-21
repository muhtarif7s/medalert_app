import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, UNUserNotificationCenterDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register notification categories/actions for actionable notifications
    let markAction = UNNotificationAction(identifier: "mark_taken", title: "Mark taken", options: [])
    let remindAction = UNNotificationAction(identifier: "remind", title: "Remind me", options: [])
    let category = UNNotificationCategory(identifier: "DOSE_CATEGORY", actions: [markAction, remindAction], intentIdentifiers: [], options: [])
    UNUserNotificationCenter.current().setNotificationCategories([category])
    UNUserNotificationCenter.current().delegate = self

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
