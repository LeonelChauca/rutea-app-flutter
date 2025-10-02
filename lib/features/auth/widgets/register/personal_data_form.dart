import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class PersonalDataForm extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;

  PersonalDataForm({required this.formKey});

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: formKey,
      child: Column(
        children: [
          FormBuilderTextField(
            name: 'nombre',
            decoration: InputDecoration(
              hintText: 'Nombre Completo',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.person, color: Colors.grey.shade300),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
            ]),
          ),
          const SizedBox(height: 15),
          FormBuilderTextField(
            name: 'p_apellido',
            decoration: InputDecoration(
              hintText: 'Apellido Paterno',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.badge, color: Colors.grey.shade300),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
            ]),
          ),
          const SizedBox(height: 15),
          FormBuilderTextField(
            name: 's_apellido',
            decoration: InputDecoration(
              hintText: 'Apellido Materno',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.badge, color: Colors.grey.shade300),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
            ]),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              // Pasa a la siguiente página (datos de usuario)
            },
            child: Text("Siguiente"),
          ),
        ],
      ),
    );
  }
}
