import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ruteaflutter/core/screens/succes_screen.dart';
import 'package:ruteaflutter/features/auth/presentation/login_page.dart';
import 'package:ruteaflutter/features/auth/presentation/register_page.dart';
import 'package:ruteaflutter/features/welcome/presentation/welcome_page.dart';
import 'package:ruteaflutter/screens/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Agrega este import

import 'theme.dart';
import 'package:intl/intl.dart';

void main() async {
  await dotenv.load();
  Intl.defaultLocale = 'es_BO';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rutea App',
      initialRoute: '/',
      locale: const Locale('es', 'BO'),
      supportedLocales: const [Locale('es', 'BO')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/welcome': (context) => const WelcomePage(),
        '/register': (context) => const RegisterPage(),
        '/success': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return SuccessScreen(
            title: args['title'] ?? 'Operación exitosa',
            description:
                args['description'] ??
                'La operación se completó correctamente.',
          );
        },
      },
      theme: AppTheme.lightTheme,
    );
  }
}
