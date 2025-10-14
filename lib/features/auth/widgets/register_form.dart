import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ruteaflutter/core/providers/providers.dart';
import 'package:ruteaflutter/features/auth/widgets/register/personal_data_form.dart';
import 'package:ruteaflutter/features/auth/widgets/register/user_data_form.dart';
import 'package:ruteaflutter/models/register_request.dart';
import 'package:ruteaflutter/utils/snackbar_util.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final GlobalKey<FormBuilderState> _personalDataFormKey =
      GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _userDataFormKey =
      GlobalKey<FormBuilderState>();

  final PageController _pageController = PageController();

  bool _isLoading = false;
  // ignore: unused_field
  String _errorMessage = '';

  Future<void> _createUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userService = ref.read(userServiceProvider);
      await userService.register(
        RegisterRequest(
          email: _userDataFormKey.currentState?.fields['email']?.value,
          password: _userDataFormKey.currentState?.fields['password']?.value,
          nombres: _personalDataFormKey.currentState?.fields['nombre']?.value,
          p_apellido:
              _personalDataFormKey.currentState?.fields['p_apellido']?.value,
          s_apellido:
              _personalDataFormKey.currentState?.fields['s_apellido']?.value,
          fecha_nacimiento: _personalDataFormKey
              .currentState
              ?.fields['fecha_nacimiento']
              ?.value,
          ci: '12345678922',
          genero: _personalDataFormKey.currentState?.fields['genero']?.value,
        ),
      );
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/success',
          arguments: {
            'title': 'Operación exitosa',
            'description': 'El registro se completó correctamente.',
          },
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      print('Registration failed with error: $e');

      if (mounted) {
        showErrorSnackbar(context, '$e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.6,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PersonalDataForm(
                    formKey: _personalDataFormKey,
                    pageController: _pageController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: UserDataForm(
                    formKey: _userDataFormKey,
                    pageController: _pageController,
                    createUser: _createUser,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
