import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ruteaflutter/features/auth/widgets/register_form.dart';
import 'package:ruteaflutter/models/login_request.dart';
import 'package:ruteaflutter/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/auth/auth.service.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  bool _isLoading = false;
  // ignore: unused_field
  String _errorMessage = '';

  Future<void> _login(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authService = AuthService();
      await authService.login(LoginRequest(email: email, password: password));
      print('Login successful');
    } catch (e) {
      print('Login failed with error: $e');
      setState(() {
        _errorMessage =
            'Error al iniciar sesión. Por favor, inténtalo de nuevo.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: Column(
          children: [
            FormBuilderTextField(
              name: 'email',
              decoration: InputDecoration(
                hintText: 'Correo Electronico',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.email, color: Colors.grey.shade300),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.email(),
              ]),
            ),
            const SizedBox(height: 20),
            FormBuilderTextField(
              name: 'password',
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Contraseña',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.lock, color: Colors.grey.shade300),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Acción al presionar el botón de iniciar sesión
                  if (_formKey.currentState!.saveAndValidate() && !_isLoading) {
                    await _login(
                      _formKey.currentState!.value['email'],
                      _formKey.currentState!.value['password'],
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    const Text(
                      'Iniciar Sesión',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes una cuenta?',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Crea una cuenta',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
