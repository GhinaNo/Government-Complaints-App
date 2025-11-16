import 'package:complaint_app/background_message_handler.dart';
import 'package:complaint_app/pages/complaint_list.dart';
import 'package:complaint_app/pages/create_complaint.dart';
import 'package:complaint_app/pages/gold_login_page.dart';
import 'package:complaint_app/pages/gold_signup_page.dart';
import 'package:complaint_app/repositories/auth_repo.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:complaint_app/services/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyC19OHwq0BeMVKw5q3nft5liuzJtnzz6RI",
      appId: "1:95532699305:android:1e9ff37061bf6953e2e3b8",
      messagingSenderId: "95532699305",
      projectId: "vendorslist-8abd3",
    ),
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Complaint App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.teal,
            scaffoldBackgroundColor: const Color(0xFF0A3C3A),
            fontFamily: 'Roboto',
            appBarTheme: const AppBarTheme(
              backgroundColor: Color.fromARGB(168, 10, 60, 58),
              elevation: 3.0,
            ),
          ),
          home: const LoginPage(),
          routes: {
            '/signup': (_) => const SignupPage(),
            '/login': (_) => const LoginPage(),
            '/create-complaint': (_) => const CreateComplaintPage(),
            '/list-complaint': (_) => const ListComplaintsPage(),
          },
        ),
      ),
    );
  }
}

