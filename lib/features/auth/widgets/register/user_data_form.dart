import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class UserDataForm extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;

  UserDataForm({required this.formKey});

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: formKey,
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
              FormBuilderValidators.required(),
              FormBuilderValidators.email(),
            ]),
          ),
          const SizedBox(height: 15),
          FormBuilderTextField(
            name: 'password',
            decoration: InputDecoration(
              hintText: 'Contraseña',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.lock, color: Colors.grey.shade300),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.minLength(6),
            ]),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              // Procesar formulario
              if (formKey.currentState?.saveAndValidate() ?? false) {
                print("Formulario válido y listo para registrar.");
              }
            },
            child: Text("Registrar"),
          ),
        ],
      ),
    );
  }
}
