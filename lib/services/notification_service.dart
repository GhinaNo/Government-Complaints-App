
import 'dart:convert';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'complaint_importance_channel',
    'High Importance Complaint Notifications',
    description:
        'This channel is used for complaint important notifications.',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    debugPrint("Initialize notification service begin");
    await _requestNotificationPermission();

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        debugPrint('Notification tapped: ${details.payload}');
        _handleNotificationTap(details.payload);
      },
    );

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    String? token = await messaging.getToken();
    debugPrint('FCM Token: $token');

    await messaging.subscribeToTopic("all_users_news");

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);


  }

  static Future<void> _requestNotificationPermission() async {
    await Permission.notification.request();
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message received: ${message.notification?.title}');

    await _showLocalNotification(
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Background message received: ${message.notification?.title}');

    await _showLocalNotification(
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          playSound: true,
          enableVibration: true,
        );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _notificationsPlugin.show(
      Random.secure().nextInt(100000000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _showLocalNotification(
      title: title,
      body: body,
      payload: payload ?? '',
    );
  }

  static Future<String?> getFcmToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  static Future<PermissionStatus> requestNotificationPermission() async {
    return await Permission.notification.request();
  }

  static void _handleNotificationTap(String? payload) {
    if (payload != null) {
      try {
        final data = jsonDecode(payload);
        debugPrint('Notification tapped with data: $data');

        final notificationType = data['data']['type'] ?? 'default';
        switch (notificationType) {
          case 'chat':
            debugPrint('Navigate to chat');
            break;
          case 'alert':
            debugPrint('Handle alert notification');
            break;
          default:
            debugPrint('Handle default notification');
        }
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }
}
