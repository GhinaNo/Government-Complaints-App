import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/http_client.dart';
import '../../../../widgets/gold_btn.dart';
import '../../../../widgets/gold_logo.dart';
import '../../../../widgets/gold_text_field.dart';
import '../core/utils/toast_services.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/models/verify_code_request.dart';
import '../features/auth/presentation/blocs/verify_code_bloc/verify_code_bloc.dart';
import '../features/auth/presentation/blocs/verify_code_bloc/verify_code_event.dart';
import '../features/auth/presentation/blocs/verify_code_bloc/verify_code_state.dart';

class VerificationPage extends StatefulWidget {
  final String email;

  const VerificationPage({super.key, required this.email});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Timer? _timer;
  int _remainingTime = 300;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  VerificationBloc _createVerificationBloc() {
    return VerificationBloc(
      remoteDataSource: AuthRemoteDataSource(
        httpClient: HttpClient(),
      ),
    );
  }

  void _handleVerification(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final request = VerificationRequest(
        email: widget.email,
        code: _codeController.text.trim(),
      );

      context.read<VerificationBloc>().add(VerificationSubmitted(request: request));
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      }
    });
  }


  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _createVerificationBloc(),
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<VerificationBloc, VerificationState>(
            listener: (context, state) {
              if (state is VerificationSuccess) {
                ToastService.showSuccess(context, "تم التحقق من الحساب بنجاح!");
                Navigator.pushReplacementNamed(context, '/list-complaint');
              } else if (state is VerificationFailure) {
                ToastService.showError(context, state.error);
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const EagleLogo(size: 120),
                    const SizedBox(height: 16),

                    const Text(
                      'التحقق من الحساب',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildVerificationMessage(),
                    const SizedBox(height: 24),

                    GoldTextField(
                      controller: _codeController,
                      hint: 'أدخل رمز التحقق',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال رمز التحقق';
                        }
                        return null;
                      },
                      keyboard: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      autofocus: true,
                      prefixIcon: const Icon(Icons.verified_user_outlined, color: Color(0xFFBFA46F)),
                    ),
                    const SizedBox(height: 30),

                    BlocBuilder<VerificationBloc, VerificationState>(
                      builder: (context, state) {
                        return GoldButton(
                          label: state is VerificationLoading ? 'جاري التحقق...' : 'تحقق من الحساب',
                          onTap: state is VerificationLoading ? null : () => _handleVerification(context),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildResendSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildVerificationMessage() {
    return Column(
      children: [
        Text(
          'أدخل رمز التحقق المرسل إلى بريدك الإلكتروني',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          widget.email,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFBFA46F),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        Text(
          'لم تستلم الرمز؟',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        _canResend
            ? GestureDetector(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFFBFA46F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFBFA46F)),
            ),
            child: Text(
              'إعادة إرسال الرمز',
              style: TextStyle(
                color: Color(0xFFBFA46F),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'يمكنك إعادة الإرسال خلال ',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            Text(
              _formatTime(_remainingTime),
              style: TextStyle(
                color: Color(0xFFBFA46F),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}