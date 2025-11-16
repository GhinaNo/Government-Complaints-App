import 'dart:async';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:complaint_app/services/login_protection_service.dart';
import 'package:complaint_app/utils/show_toast.dart';
import 'package:complaint_app/utils/validate.dart';
import 'package:complaint_app/widgets/gold_btn.dart';
import 'package:complaint_app/widgets/gold_logo.dart';
import 'package:complaint_app/widgets/gold_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
  Timer? _countdownTimer;
  int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_checkAccountStatus);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isAccountLocked) {
        setState(() {
          _refreshCounter++;
        });

        if (!_isAccountLocked) {
          timer.cancel();
          setState(() {});
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _checkAccountStatus() {
    final email = _emailCtrl.text.trim();
    if (email.isNotEmpty) {
      setState(() {});

      if (_isAccountLocked && (_countdownTimer == null || !_countdownTimer!.isActive)) {
        _startCountdownTimer();
      }
    }
  }

  bool get _isAccountLocked {
    final email = _emailCtrl.text.trim();
    return LoginProtectionService.isAccountLocked(email);
  }

  bool get _isTooFast {
    final email = _emailCtrl.text.trim();
    return LoginProtectionService.isTooFast(email);
  }

  int get _remainingAttempts {
    final email = _emailCtrl.text.trim();
    return LoginProtectionService.getRemainingAttempts(email);
  }

  String get _remainingTimeText {
    final email = _emailCtrl.text.trim();
    final remainingTime = LoginProtectionService.getRemainingLockTime(email);
    return LoginProtectionService.formatRemainingTime(remainingTime);
  }

  void _login() async {
    if (_isAccountLocked) {
      debugPrint('🚫 Login blocked - Account is locked');
      _showAccountLockedError();
      return;
    }

    if (_isTooFast) {
      debugPrint('⏰ Login blocked - Too fast');
      _showTooFastError();
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      LoginProtectionService.recordAttemptTime(_emailCtrl.text.trim());

      // ديبق قبل المحاولة
      debugPrint('🎯 Starting login attempt for: ${_emailCtrl.text.trim()}');
      LoginProtectionService.debugAccountStatus(_emailCtrl.text.trim());

      try {
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );

        debugPrint('✅ Login successful for: ${_emailCtrl.text.trim()}');
        LoginProtectionService.recordSuccessfulAttempt(_emailCtrl.text.trim());

        final user = userCredential.user;
        if (user != null) {
          user.reload();
        }
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
          if (mounted) {
            showToast(
              context: context,
              title: "Verify your email first",
              msg: "Please verify your email. Verification link sent.",
              type: ContentType.warning,
            );
          }
          await FirebaseAuth.instance.signOut();
        } else if (user != null && user.emailVerified) {
          if (mounted) {
            showToast(
              context: context,
              title: "Welcome Back!",
              msg: "Successfully logged in to your account",
            );
            Navigator.of(context).pushReplacementNamed('/list-complaint');
          }
        }
      } on FirebaseAuthException catch (e) {
        debugPrint('❌ Login failed with error: ${e.code}');

        if (_shouldRecordFailedAttempt(e.code)) {
          debugPrint('📝 Recording failed attempt for error: ${e.code}');
          LoginProtectionService.recordFailedAttempt(_emailCtrl.text.trim());
        } else {
          debugPrint('⏭️ Skipping failed attempt recording for error: ${e.code}');
        }

        String msg = _getErrorMessage(e.code);

        if (e.code == 'user-not-found') {
          msg = "No account found. Please create an account first.";
        }

        debugPrint("The code is: ${e.code}");

        if (mounted) {
          showToast(
            context: context,
            title: "Login Failed",
            msg: msg,
            type: ContentType.failure,
          );
        }

        if (_isAccountLocked) {
          debugPrint('🔒 Account now locked - Starting countdown timer');
          _startCountdownTimer();
        }

        LoginProtectionService.debugAccountStatus(_emailCtrl.text.trim());
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _shouldRecordFailedAttempt(String errorCode) {
    switch (errorCode) {
      case 'invalid-credential':
      case 'wrong-password':
        return true;
      case 'user-not-found':
      case 'user-disabled':
      case 'too-many-requests':
      default:
        return false;
    }
  }
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-credential':
        return "Invalid email or password";
      case 'user-disabled':
        return "This account has been disabled";
      case 'user-not-found':
        return "No account found with this email";
      case 'wrong-password':
        return "Incorrect password";
      case 'too-many-requests':
        return "Too many attempts. Please try again later.";
      default:
        return "Login failed. Please try again.";
    }
  }

  void _showAccountLockedError() {
    showToast(
      context: context,
      title: "Account Locked",
      msg: "Too many failed attempts. Please try again in 15 minutes.",
      type: ContentType.failure,
    );
  }

  void _showTooFastError() {
    showToast(
      context: context,
      title: "Slow Down",
      msg: "Please wait a few seconds before trying again.",
      type: ContentType.warning,
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Build called - Refresh counter: $_refreshCounter');

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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: const Column(
                    children: [
                      Text(
                        'Welcome Back, Dear Citizen!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your voice matters. Sign in to continue making a difference in a free Syria.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                if (_isAccountLocked || (_emailCtrl.text.isNotEmpty && _remainingAttempts < 5))
                  _buildSecurityStatusCard(),

                const SizedBox(height: 24),

                Column(
                  children: [
                    GoldTextField(
                      controller: _emailCtrl,
                      hint: 'Email ',
                      validator: (value) {
                        if (_isAccountLocked) {
                          return 'Account temporarily locked';
                        }
                        return Validate.validateEmail(value);
                      },
                      keyboard: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    const SizedBox(height: 16),

                    GoldTextField(
                      controller: _passCtrl,
                      hint: 'Password',
                      validator: (value) {
                        if (_isAccountLocked) return null;
                        return Validate.validateLoginPassword(value);
                      },
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
                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Color(0xFFBFA46F)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    GoldButton(
                      label: 'Sign In to Your Account',
                      onTap: _isLoading ? null : _login,
                      isLoading: _isLoading,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "New to our service? ",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/signup'),
                        child: const Text(
                          "Create Account",
                          style: TextStyle(
                            color: Color(0xFFBFA46F),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityStatusCard() {
    if (_isAccountLocked) {
      return _buildLockedCardWithTimer();
    }

    if (_remainingAttempts <= 2) {
      return _buildStatusCard(
        icon: Icons.warning_amber_rounded,
        title: "Security Alert",
        message: "Only $_remainingAttempts attempts remaining. Your account will be locked after 5 failed attempts.",
        color: Colors.red,
      );
    }

    if (_remainingAttempts < 5) {
      return _buildStatusCard(
        icon: Icons.security_rounded,
        title: "Security Notice",
        message: "You have $_remainingAttempts login attempts remaining.",
        color: Colors.orange,
      );
    }

    return const SizedBox();
  }

  Widget _buildLockedCardWithTimer() {
    final remainingTime = LoginProtectionService.getRemainingLockTime(_emailCtrl.text.trim());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_clock_rounded, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Account Temporarily Locked",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "For your security, this account has been locked. Please try again in $_remainingTimeText.",
                  style: TextStyle(
                    color: Colors.orange.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
                // const SizedBox(height: 8),
                // LinearProgressIndicator(
                //   value: _getLockProgressValue(),
                //   backgroundColor: Colors.orange.withOpacity(0.2),
                //   color: Colors.orange,
                //   minHeight: 4,
                //   borderRadius: BorderRadius.circular(2),
                // ),
                // const SizedBox(height: 4),
                // Text(
                //   'Time remaining: $_remainingTimeText',
                //   style: TextStyle(
                //     color: Colors.orange,
                //     fontSize: 10,
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getLockProgressValue() {
    final email = _emailCtrl.text.trim();
    final remainingTime = LoginProtectionService.getRemainingLockTime(email);
    final totalSeconds = LoginProtectionService.lockDuration.inSeconds;
    final remainingSeconds = remainingTime.inSeconds;

    if (remainingSeconds <= 0) return 0.0;
    return 1.0 - (remainingSeconds / totalSeconds);
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required String message,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: color.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}