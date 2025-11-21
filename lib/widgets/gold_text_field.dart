import 'package:flutter/material.dart';

class GoldTextField extends StatelessWidget {
  const GoldTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboard = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon,
    this.suffixIcon,
    required this.validator,
    this.strengthColor,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType keyboard;
  final TextInputAction textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String? value) validator;
  final Color? strengthColor;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFBFA46F);

    final borderColor = strengthColor ??
        (controller.text.isEmpty ? Colors.white24 : gold);

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboard,
      textInputAction: textInputAction,
      autofocus: autofocus,
      textAlign: TextAlign.right,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: strengthColor ?? Colors.white24,
            width: strengthColor != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: strengthColor ?? gold,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}