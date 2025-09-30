import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ruteaflutter/features/auth/presentation/login_page.dart';
import 'package:ruteaflutter/features/welcome/presentation/welcome_page.dart';
import 'package:ruteaflutter/screens/splash_screen.dart';
import 'theme.dart';

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rutea App',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/welcome': (context) => const WelcomePage(),
      },
      theme: AppTheme.lightTheme,
    );
  }
}
