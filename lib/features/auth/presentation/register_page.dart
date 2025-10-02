import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ruteaflutter/features/auth/widgets/register_form.dart';
import 'package:ruteaflutter/theme.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                MediaQuery.of(context).padding.top,
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ), // Usamos SizedBox en lugar de Expanded
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 70),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(100),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Text(
                      'Crea tu cuenta',
                      style: GoogleFonts.poppins(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '¿Listo para no perderte nunca más? \n Registrate y empieza a descubrir tus rutas.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    const SizedBox(height: 40),
                    const RegisterForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
