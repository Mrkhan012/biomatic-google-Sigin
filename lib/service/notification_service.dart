import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initFirebaseMessaging(
    GlobalKey<NavigatorState> navigatorKey,
    String? userName,
  ) async {
    final fcm = FirebaseMessaging.instance;

    final token = await fcm.getToken();
    print("📱 FCM Token: $token");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Foreground message received: ${message.notification?.title}');

      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        if (navigatorKey.currentContext != null) {
         showCupertinoDialog(
  context: navigatorKey.currentContext!,
  builder: (context) {
    return CupertinoAlertDialog(
      title: const Text("🚨 Alert"),
      content: Text(
        "${userName ?? 'User'} has reached the station.\n\nMessage: ${notification.body ?? 'No details'}",
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          child: const Text("OK"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  },
);
        }
      }
    });
  }

  static Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _localNotificationsPlugin.initialize(settings);
  }

  static Future<void> backgroundHandler(RemoteMessage message) async {
    print('🔔 Background message: ${message.messageId}');
  }
}
