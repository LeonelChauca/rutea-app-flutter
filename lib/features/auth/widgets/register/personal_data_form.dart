import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class PersonalDataForm extends StatefulWidget {
  final GlobalKey<FormBuilderState> formKey;
  final PageController pageController;

  final VoidCallback? createUser;

  PersonalDataForm({
    required this.formKey,
    required this.pageController,
    this.createUser,
  });

  @override
  State<PersonalDataForm> createState() => _PersonalDataFormState();
}

class _PersonalDataFormState extends State<PersonalDataForm>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // IMPORTANTE: llamar a super.build()

    return FormBuilder(
      key: widget.formKey,
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
              FormBuilderValidators.required(errorText: 'Nombre requerido'),
            ]),
          ),
          const SizedBox(height: 10),
          FormBuilderTextField(
            name: 'p_apellido',
            decoration: InputDecoration(
              hintText: 'Apellido Paterno',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.badge, color: Colors.grey.shade300),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'A. Paterno requerido'),
            ]),
          ),
          const SizedBox(height: 10),
          FormBuilderTextField(
            name: 's_apellido',
            decoration: InputDecoration(
              hintText: 'Apellido Materno',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.badge, color: Colors.grey.shade300),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'A. Materno requerido'),
            ]),
          ),
          const SizedBox(height: 10),
          FormBuilderDateTimePicker(
            name: 'fecha_nacimiento',
            inputType: InputType.date,
            initialDate: DateTime.now(),
            decoration: InputDecoration(
              hintText: 'Fecha de Nacimiento',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.cake, color: Colors.grey.shade300),
            ),
            transitionBuilder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  datePickerTheme: DatePickerThemeData(
                    backgroundColor: Colors.grey.shade200,
                    headerBackgroundColor: Colors.blue,
                    dayStyle: TextStyle(color: Colors.black),
                  ),
                ),
                child: child!,
              );
            },
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'Fecha de nacimiento requerida',
              ),
            ]),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          FormBuilderDropdown<String>(
            name: 'genero',
            decoration: InputDecoration(
              hintText: 'Género',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.wc, color: Colors.grey.shade300),
            ),
            dropdownColor: Colors.white,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Género requerido'),
            ]),
            items: [
              DropdownMenuItem(value: 'M', child: Text('Masculino')),
              DropdownMenuItem(value: 'F', child: Text('Femenino')),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 30),
            ),
            onPressed: () {
              if (widget.formKey.currentState?.saveAndValidate() ?? false) {
                print(
                  "Datos personales válidos: " +
                      (widget.formKey.currentState?.value.toString() ?? ''),
                );
                widget.pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                print("Error en el formulario de datos personales");
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Siguiente"),
                const SizedBox(width: 9),
                const Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
