import 'dart:convert';
import 'package:complaint_app/services/notification_service.dart';

class AlertService {
  static Future<void> sendSecurityAlert({
    required String email,
    required String alertType,
    required String title,
    required String message,
  }) async {
    try {
      await _sendPushNotification(title, message, alertType);
      _logSecurityEvent(email, alertType);

    } catch (e) {
      print('Error sending security alert: $e');
    }
  }

  static Future<void> _sendPushNotification(String title, String message, String alertType) async {
    try {
      await NotificationService.showLocalNotification(
        title: title,
        body: message,
        payload: jsonEncode({
          'type': 'security_alert',
          'alert_type': alertType,
          'timestamp': DateTime.now().toString(),
        }),
      );
      print('📱 Security push notification sent: $title');
    } catch (e) {
      print('Error sending security push notification: $e');
    }
  }

  static void _logSecurityEvent(String email, String alertType) {
    print('🔐 SECURITY EVENT LOGGED');
    print('User: $email');
    print('Event: $alertType');
    print('Time: ${DateTime.now()}');
    print('------------------------');
  }

  static Future<void> sendAccountLockedAlert(String email) async {
    await sendSecurityAlert(
      email: email,
      alertType: 'account_locked',
      title: '🔒 Account Locked - Security Alert',
      message: 'Your account has been temporarily locked due to multiple failed login attempts. The lock will be automatically removed after 15 minutes. If this wasn\'t you, please contact support immediately.',
    );
  }

  static Future<void> sendSuspiciousActivityAlert(String email, int failedAttempts) async {
    await sendSecurityAlert(
      email: email,
      alertType: 'suspicious_activity',
      title: '⚠️ Suspicious Activity Detected',
      message: 'We detected $failedAttempts failed login attempts on your account. If this wasn\'t you, please secure your account immediately.',
    );
  }

  static Future<void> sendFailedLoginAlert(String email, int attemptCount) async {
    await sendSecurityAlert(
      email: email,
      alertType: 'failed_login',
      title: '🚫 Failed Login Attempt',
      message: 'There was a failed login attempt on your account. Attempt #$attemptCount of 5.',
    );
  }
}