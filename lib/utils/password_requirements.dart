import 'package:complaint_app/utils/validate.dart';
import 'package:flutter/material.dart';

class PasswordRequirements extends StatelessWidget {
  final String password;

  const PasswordRequirements({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final requirements = Validate.checkPasswordRequirements(password);
    final metCount = requirements.values.where((met) => met).length;
    final strengthColor = Validate.getPasswordStrengthColor(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: metCount / 5,
          backgroundColor: Colors.grey[300],
          color: strengthColor,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 12),
        Text(
          _getStrengthText(metCount),
          style: TextStyle(
            color: strengthColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'يجب أن تحتوي كلمة المرور على:',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildRequirementItem(' أحرف على الأقل 8', requirements['8_characters']!),
        _buildRequirementItem('حرف كبير واحد على الأقل (A-Z)', requirements['uppercase']!),
        _buildRequirementItem('حرف صغير واحد على الأقل (a-z)', requirements['lowercase']!),
        _buildRequirementItem('رقم واحد على الأقل(0-9)', requirements['number']!),
        _buildRequirementItem('رمز خاص واحد على الأقل (!@#\$...)', requirements['special_char']!),
      ],
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isMet ? Colors.green : Colors.grey,
                fontSize: 12,
                decoration: isMet ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStrengthText(int metCount) {
    switch (metCount) {
      case 5:
        return 'كلمة مرور قوية ✓';
      case 4:
      case 3:
        return 'كلمة مرور متوسطة';
      case 2:
        return 'كلمة مرور ضعيفة';
      default:
        return 'كلمة مرور ضعيفة جداً';
    }
  }
}