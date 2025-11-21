import 'package:complaint_app/pages/gold_verification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/http_client.dart';
import '../../../../utils/validate.dart';
import '../../../../utils/password_requirements.dart';
import '../../../../widgets/gold_btn.dart';
import '../../../../widgets/gold_logo.dart';
import '../../../../widgets/gold_text_field.dart';
import '../core/utils/toast_services.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/models/register_request.dart';
import '../features/auth/presentation/blocs/register_bloc/register_bloc.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
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

  RegisterBloc _createRegisterBloc() {
    return RegisterBloc(
      remoteDataSource: AuthRemoteDataSource(
        httpClient: HttpClient(),
      ),
    );
  }

  void _handleSignup(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final request = RegisterRequest(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        password: _passCtrl.text,
        passwordConfirmation: _confirmCtrl.text,
      );

      context.read<RegisterBloc>().add(RegisterSubmitted(request: request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _createRegisterBloc(),
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<RegisterBloc, RegisterState>(
            listener: (context, state) {
              if (state is RegisterSuccess) {
                ToastService.showSuccess(context, "تم إنشاء الحساب بنجاح! تحقق من بريدك الإلكتروني.");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerificationPage(
                      email: _emailCtrl.text.trim(),
                    ),
                  ),
                );
              } else if (state is RegisterFailure) {
                ToastService.showError(context, state.error);
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const EagleLogo(size: 140),
                    const SizedBox(height: 12),
                    const Text(
                      'إنشاء حساب جديد',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),

                    GoldTextField(
                      controller: _nameCtrl,
                      hint: 'الاسم الكامل',
                      validator: Validate.validateName,
                      prefixIcon: const Icon(Icons.person_outline,color: Color(0xFFBFA46F)),
                      keyboard: TextInputType.name,
                    ),
                    const SizedBox(height: 16),

                    GoldTextField(
                      controller: _emailCtrl,
                      hint: 'البريد الإلكتروني',
                      validator: Validate.validateEmail,
                      keyboard: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined,color: Color(0xFFBFA46F),),
                    ),
                    const SizedBox(height: 16),

                    GoldTextField(
                      controller: _phoneCtrl,
                      hint: 'رقم الهاتف',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال رقم الهاتف';
                        }
                        return null;
                      },
                      keyboard: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined,color: Color(0xFFBFA46F))
                    ),
                    const SizedBox(height: 16),

                    if (_passCtrl.text.isNotEmpty)
                      PasswordRequirements(password: _passCtrl.text),

                    GoldTextField(
                      controller: _passCtrl,
                      hint: 'كلمة المرور',
                      validator: Validate.validatePassword,
                      obscure: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outline,color: Color(0xFFBFA46F)),
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

                    GoldTextField(
                      controller: _confirmCtrl,
                      hint: 'تأكيد كلمة المرور',
                      validator: (txt) => Validate.validateConfirm(txt, _passCtrl),
                      obscure: _obscureConfirmPassword,
                      prefixIcon: const Icon(Icons.lock_outline,color: Color(0xFFBFA46F)),
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

                    BlocBuilder<RegisterBloc, RegisterState>(
                      builder: (context, state) {
                        return GoldButton(
                          label: state is RegisterLoading ? 'جاري إنشاء الحساب....' : 'إنشاء حساب',
                          onTap: state is RegisterLoading ? null : () => _handleSignup(context),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text(
                        "لديك حساب مسبقاً؟ تسجيل الدخول",
                        style: TextStyle(color: Color(0xFFBFA46F)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }
}