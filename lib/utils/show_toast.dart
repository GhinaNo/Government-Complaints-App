import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

void showToast({
  required BuildContext context,
  required String title,
  required String msg,
  ContentType type = ContentType.success,
}) {
  final overlayState = Overlay.of(context);
  if (overlayState == null) return;

  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).viewPadding.top + 50,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        elevation: 6,
        child: AwesomeSnackbarContent(
          title: title,
          message: msg,
          contentType: type,
        ),
      ),
    ),
  );

  overlayState.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 4), () {
    overlayEntry.remove();
  });
}