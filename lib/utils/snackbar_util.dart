// lib/utils/snackbar_util.dart

import 'package:flutter/material.dart';

void showErrorSnackbar(BuildContext context, String errorMessage) {
  final snackBar = SnackBar(
    content: Text(
      errorMessage,
      style: TextStyle(color: Colors.white), // Texto blanco
    ),
    backgroundColor: Colors.red, // Fondo rojo para el error
    duration: Duration(seconds: 3), // Duración de la visibilidad del mensaje
    action: SnackBarAction(
      label: 'Cerrar', // Acción del snackbar
      textColor: Colors.white, // Color del texto de la acción
      onPressed: () {},
    ),
  );

  // Muestra el snackbar
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
