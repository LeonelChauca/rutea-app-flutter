import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colores personalizados extraídos de las imágenes
  static const Color primaryColor = Color(
    0xFF3B9DC2,
  ); // Lavanda claro (Botones)
  static const Color colorSec = Color(0xFFFBFBFB); // Blanco muy claro (Fondo)
  static const Color secondaryColor = Color(
    0xFF0D4556,
  ); // Tono de lavanda para otros elementos
  static const Color accentColor = Color(
    0xFFB99BE5,
  ); // Variación de lavanda claro

  // Tema claro (light theme) con colorScheme
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: accentColor,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(200, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 10),
        elevation: 0,
        backgroundColor: secondaryColor,
        foregroundColor: colorSec, // el texto se pone blanco automáticamente
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: primaryColor), // Usamos el color primario
    ),
    inputDecorationTheme: InputDecorationTheme(
      // Estilo global de los bordes
      errorStyle: const TextStyle(
        color: Colors.red, // Color del texto de error
        fontSize: 14, // Tamaño del texto de error
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide.none, // Sin borde
        borderRadius: BorderRadius.circular(10),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ), // Borde de error al enfocar
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade500),
        borderRadius: BorderRadius.circular(15),
      ),
    ),
  );
}
