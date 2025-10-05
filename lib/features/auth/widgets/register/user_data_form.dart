import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class UserDataForm extends StatefulWidget {
  final GlobalKey<FormBuilderState> formKey;
  final PageController pageController;
  final Future<void> Function() createUser;
  final bool isLoading; // ✅ Nuevo prop

  UserDataForm({
    required this.formKey,
    required this.pageController,
    required this.createUser,
    this.isLoading = false,
  });

  @override
  State<UserDataForm> createState() => _UserDataFormState();
}

class _UserDataFormState extends State<UserDataForm>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FormBuilder(
      key: widget.formKey,
      child: Column(
        children: [
          FormBuilderTextField(
            keyboardType: TextInputType.emailAddress,
            name: 'email',
            decoration: InputDecoration(
              hintText: 'Correo Electrónico',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.email, color: Colors.grey.shade300),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Email requerido'),
              FormBuilderValidators.email(errorText: 'Email inválido'),
            ]),
          ),
          const SizedBox(height: 15),
          FormBuilderTextField(
            name: 'password',
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Contraseña',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.lock, color: Colors.grey.shade300),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade300,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Contraseña requerida'),
              FormBuilderValidators.minLength(
                6,
                errorText: 'Mínimo 6 caracteres',
              ),
            ]),
          ),
          const SizedBox(height: 15),
          FormBuilderTextField(
            name: 'confirm_password',
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              hintText: 'Reescribir Contraseña',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade300),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey.shade300,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'Confirma tu contraseña',
              ),
              (val) {
                var password =
                    widget.formKey.currentState?.fields['password']?.value;
                if (val != password) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ]),
          ),
          const SizedBox(height: 15),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed:
                widget
                    .isLoading // ✅ Usar widget.isLoading
                ? null
                : () {
                    if (widget.pageController.hasClients) {
                      widget.pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back),
                SizedBox(width: 10),
                Text("Atrás"),
              ],
            ),
          ),
          const SizedBox(height: 15),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: widget.isLoading
                ? null
                : () async {
                    if (widget.formKey.currentState?.saveAndValidate() ??
                        false) {
                      print('ok');
                      await widget.createUser();
                    }
                  },
            child: widget.isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add),
                      SizedBox(width: 10),
                      Text("Registrar"),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
