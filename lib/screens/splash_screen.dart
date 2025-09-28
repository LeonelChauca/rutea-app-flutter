import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ruteaflutter/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _startAnimation = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() {
        _startAnimation = true; // Comienza la animación después del retraso
      });
      navigateToWelcomePage(); // Navegar a la siguiente página
    });
  }

  void navigateToWelcomePage() {
    Timer(const Duration(seconds: 1), () {
      Navigator.pushNamed(context, '/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 1.0, end: _startAnimation ? 0.0 : 1.0),
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: SvgPicture.asset(
                'assets/logo.svg',
                height: 150,
                width: 150,
                colorFilter: ColorFilter.mode(
                  AppTheme.colorSec,
                  BlendMode.srcIn,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
