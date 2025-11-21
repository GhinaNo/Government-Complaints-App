import 'package:complaint_app/background_message_handler.dart';
import 'package:complaint_app/pages/complaint_list.dart';
import 'package:complaint_app/pages/create_complaint.dart';
import 'package:complaint_app/pages/gold_login_page.dart';
import 'package:complaint_app/pages/gold_signup_page.dart';
import 'package:complaint_app/pages/gold_verification_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:complaint_app/services/notification_service.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();

// Initialize firebase
await Firebase.initializeApp(
options: FirebaseOptions(
apiKey: "AIzaSyC19OHwq0BeMVKw5q3nft5liuzJtnzz6RI",
appId: "1:95532699305:android:1e9ff37061bf6953e2e3b8",
messagingSenderId: "95532699305",
projectId: "vendorslist-8abd3",
),
);

// Register the background message handler BEFORE initializing notification service
FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

// Initialize notification service
await NotificationService.initialize();

runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Complaint App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF0A3C3A),
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(168, 10, 60, 58),
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
    );
  }
}

