import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'app_messages.dart';

class ToastService {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required ContentType type,
    Duration duration = const Duration(seconds: 4),
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      duration: duration,
      content: AwesomeSnackbarContent(
        title: title,
        message: _truncateArabicMessage(message),
        contentType: type,
        messageTextStyle: TextStyle(fontSize: 14),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static String _truncateArabicMessage(String message) {
    if (message.length > 120) {
      return '${message.substring(0, 120)}...';
    }
    return message;
  }


  static void showSuccess(BuildContext context, String message, {String title = AppTitles.success}) {
    show(
      context: context,
      title: title,
      message: message,
      type: ContentType.success,
    );
  }

  static void showError(BuildContext context, String message, {String title = AppTitles.error}) {
    show(
      context: context,
      title: title,
      message: message,
      type: ContentType.failure,
    );
  }

  static void showWarning(BuildContext context, String message, {String title = AppTitles.warning}) {
    show(
      context: context,
      title: title,
      message: message,
      type: ContentType.warning,
    );
  }

  static void showInfo(BuildContext context, String message, {String title = AppTitles.info}) {
    show(
      context: context,
      title: title,
      message: message,
      type: ContentType.help,
    );
  }

  static void hideAll(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}