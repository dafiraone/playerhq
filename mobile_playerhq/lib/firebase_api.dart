import "dart:developer";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  log("title ${message.notification?.title}");
  log("body ${message.notification?.body}");
  log("payload ${message.data}");
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();

    final settings = await _firebaseMessaging.requestPermission();
    log("Notification permission status: ${settings.authorizationStatus}");

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    final fcmToken = await _firebaseMessaging.getToken();
    log("FCM Token: $fcmToken");

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("Title: ${message.notification?.title}");
      log("Body: ${message.notification?.body}");
      _showNotification(message);
    });
  }

  Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = notification?.android;

    if (notification != null && android != null) {
      const androidDetails = AndroidNotificationDetails(
        'default_channel',
        'Default Channel',
        channelDescription: 'This is the default notification channel.',
        importance: Importance.high,
        priority: Priority.high,
      );
      const notificationDetails = NotificationDetails(android: androidDetails);

      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
      );
    }
  }

  // Method to get token for display
  Future<String?> getToken() async {
    final fcmToken = await _firebaseMessaging.getToken();
    return fcmToken;
  }
}
