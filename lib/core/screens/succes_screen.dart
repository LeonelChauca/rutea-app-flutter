import 'package:flutter/material.dart';

class SuccessScreen extends StatefulWidget {
  final String title;
  final String description;

  const SuccessScreen({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador de la animación
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    // Animación de escala para hacer crecer el ícono de "check"
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Animación de opacidad para que el contenido se desvanezca al entrar
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Iniciar la animación
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Fondo circular con el ícono de "check" y animación
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.shade50, // Color de fondo claro
                    ),
                  ),
                  ScaleTransition(
                    scale: _scaleAnimation, // Aplica la animación de escala
                    child: FadeTransition(
                      opacity:
                          _fadeAnimation, // Aplica la animación de opacidad
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red, // Círculo rojo central
                        ),
                        child: Icon(Icons.check, color: Colors.white, size: 60),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Texto principal "successful!" (Usamos el título pasado como prop)
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  widget.title, // Título personalizado
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Texto adicional (Usamos la descripción pasada como prop)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    widget.description, // Descripción personalizada
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Botón de cerrar
              FadeTransition(
                opacity: _fadeAnimation,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/welcome');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Color de fondo del botón
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ), // Borde redondeado
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
