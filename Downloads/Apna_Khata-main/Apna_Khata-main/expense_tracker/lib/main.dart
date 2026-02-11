import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/firebase_options.dart';
import 'package:expense_tracker/utils/app_theme.dart';
import 'package:expense_tracker/screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase Init Error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intelligent Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      //  TEMPORARY: Bypass SplashScreen
      home: const AuthGate(),

      // If you want pure debug test instead, use this:
      /*
      home: const Scaffold(
        body: Center(
          child: Text("App Running Successfully"),
        ),
      ),
      */
    );
  }
}
