import 'package:complaint_app/services/AlertService.dart';
import 'package:flutter/material.dart';

class LoginAttempt {
  String email;
  int attemptCount;
  DateTime lastAttempt;
  bool isLocked;
  DateTime? lockedUntil;

  LoginAttempt({
    required this.email,
    this.attemptCount = 0,
    DateTime? lastAttempt,
    this.isLocked = false,
    this.lockedUntil,
  }) : lastAttempt = lastAttempt ?? DateTime.now();
}

class LoginProtectionService {
  static final Map<String, LoginAttempt> _loginAttempts = {};
  static const int _maxAttempts = 5;
  static const Duration _lockDuration = Duration(minutes: 15);
  static const Duration _minTimeBetweenAttempts = Duration(seconds: 3);
  static final Map<String, DateTime> _lastAttemptTime = {};

  static Duration get lockDuration => _lockDuration;

  static bool isAccountLocked(String email) {
    final attempt = _loginAttempts[email];
    if (attempt == null) return false;

    if (attempt.isLocked && attempt.lockedUntil!.isAfter(DateTime.now())) {
      return true;
    }

    if (attempt.isLocked && attempt.lockedUntil!.isBefore(DateTime.now())) {
      _resetAttempts(email);
      return false;
    }

    return false;
  }

  static Duration getRemainingLockTime(String email) {
    final attempt = _loginAttempts[email];
    if (attempt == null || !attempt.isLocked || attempt.lockedUntil == null) {
      return Duration.zero;
    }

    final now = DateTime.now();
    final remaining = attempt.lockedUntil!.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  static String formatRemainingTime(Duration duration) {
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${duration.inSeconds} seconds';
  }

  static bool isTooFast(String email) {
    final lastTime = _lastAttemptTime[email];
    if (lastTime == null) return false;

    final timeSinceLastAttempt = DateTime.now().difference(lastTime);
    return timeSinceLastAttempt < _minTimeBetweenAttempts;
  }

  static void recordFailedAttempt(String email) {
    var attempt = _loginAttempts[email] ?? LoginAttempt(email: email);

    debugPrint('=== LOGIN PROTECTION DEBUG ===');
    debugPrint('Email: $email');
    debugPrint('Previous attempts: ${attempt.attemptCount}');

    attempt.attemptCount++;
    attempt.lastAttempt = DateTime.now();

    debugPrint('New attempt count: ${attempt.attemptCount}');

    _handleSecurityAlerts(email, attempt.attemptCount);

    if (attempt.attemptCount >= _maxAttempts) {
      debugPrint('🔒 ACCOUNT LOCKED - Reached max attempts');
      attempt.isLocked = true;
      attempt.lockedUntil = DateTime.now().add(_lockDuration);
      _sendLockoutNotification(email);
    } else {
      debugPrint('⚠️ Attempt recorded, not locked yet');
    }

    _loginAttempts[email] = attempt;
    _lastAttemptTime[email] = DateTime.now();
    debugPrint('==============================');
  }

  static void _handleSecurityAlerts(String email, int attemptCount) {
    switch (attemptCount) {
      case 1:
        debugPrint('📝 First failed attempt for: $email');
        break;
      case 2:
        AlertService.sendFailedLoginAlert(email, attemptCount);
        break;
      case 3:
        AlertService.sendSuspiciousActivityAlert(email, attemptCount);
        break;
      case 4:
        AlertService.sendFailedLoginAlert(email, attemptCount);
        break;
    }
  }

  static void _sendLockoutNotification(String email) {
    debugPrint('🔐 Account locked: $email for 15 minutes');
    AlertService.sendAccountLockedAlert(email);
  }

  static void recordSuccessfulAttempt(String email) {
    _resetAttempts(email);
  }

  static void recordAttemptTime(String email) {
    _lastAttemptTime[email] = DateTime.now();
  }

  static void _resetAttempts(String email) {
    _loginAttempts.remove(email);
    _lastAttemptTime.remove(email);
  }

  static int getRemainingAttempts(String email) {
    final attempt = _loginAttempts[email];
    if (attempt == null) return _maxAttempts;
    return _maxAttempts - attempt.attemptCount;
  }

  static void debugAccountStatus(String email) {
    final attempt = _loginAttempts[email];
    if (attempt == null) {
      debugPrint('🔍 No login attempts recorded for: $email');
      return;
    }

    debugPrint('=== ACCOUNT STATUS DEBUG ===');
    debugPrint('Email: $email');
    debugPrint('Attempts: ${attempt.attemptCount}/$_maxAttempts');
    debugPrint('Is Locked: ${attempt.isLocked}');
    debugPrint('Locked Until: ${attempt.lockedUntil}');
    debugPrint('Remaining Time: ${getRemainingLockTime(email)}');
    debugPrint('============================');
  }
}