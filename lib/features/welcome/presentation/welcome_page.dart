import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Asegúrate de usar el paquete correcto
import 'package:google_fonts/google_fonts.dart';
import 'package:ruteaflutter/theme.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.8,
          heightFactor: 0.8,
          child: Column(
            children: [
              Column(
                children: [
                  SvgPicture.asset(
                    'assets/logo.svg',
                    height: 150,
                    width: 150,
                    colorFilter: ColorFilter.mode(
                      AppTheme.colorSec,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Bienvenido a Rutea!',
                    style: GoogleFonts.poppins(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.colorSec,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Tu app de informacion de rutas en La Paz,\n Inicia sesión o crea tu cuenta \n y comienza a rutear.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppTheme.colorSec,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Column(
                children: [
                  SizedBox(
                    width: 200,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        'Crear Cuenta',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.colorSec,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 200,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text(
                        'Iniciar Sesión',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.colorSec,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
