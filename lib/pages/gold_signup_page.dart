import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:complaint_app/utils/show_toast.dart';
import 'package:complaint_app/utils/validate.dart';
import 'package:complaint_app/widgets/gold_btn.dart';
import 'package:complaint_app/widgets/gold_logo.dart';
import 'package:complaint_app/widgets/gold_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/password_requirements.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _passCtrl.addListener(() {
      setState(() {});
    });
  }

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      try {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );

        await credential.user!.sendEmailVerification();

        if (mounted) {
          showToast(
            context: context,
            title: "",
            msg: "Verification email sent! Please check your inbox.",
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'weak-password') {
          message = 'Password should be at least 6 characters.';
        } else if (e.code == 'email-already-in-use') {
          message = 'An account already exists for that email.';
        } else if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          message = 'Invalid email or password.';
        } else {
          message = e.message ?? 'An error occurred.';
        }
        if (mounted) {
          showToast(
            context: context,
            title: 'Check Input Data',
            msg: message,
            type: ContentType.failure,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const EagleLogo(size: 140),
                const SizedBox(height: 32),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // Full Name
                GoldTextField(
                  controller: _nameCtrl,
                  hint: 'Full Name',
                  validator: Validate.validateName,
                  prefixIcon: const Icon(Icons.person_outline),
                  keyboard: TextInputType.name,
                ),
                const SizedBox(height: 16),

                // Email
                GoldTextField(
                  controller: _emailCtrl,
                  hint: 'Email',
                  validator: Validate.validateEmail,
                  keyboard: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 16),

                // Password Requirements - MOVE TO TOP for better visibility
                if (_passCtrl.text.isNotEmpty)
                  PasswordRequirements(password: _passCtrl.text),

                // Password Field
                GoldTextField(
                  controller: _passCtrl,
                  hint: 'Password',
                  validator: Validate.validatePassword,
                  obscure: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                GoldTextField(
                  controller: _confirmCtrl,
                  hint: 'Confirm Password',
                  validator: (txt) => Validate.validateConfirm(txt, _passCtrl),
                  obscure: _obscureConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 28),

                // Sign Up Button
                GoldButton(label: 'Sign Up', onTap: _signup),
                const SizedBox(height: 20),

                // Login Link
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(color: Color(0xFFBFA46F)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}