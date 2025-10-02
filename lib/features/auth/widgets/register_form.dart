import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ruteaflutter/features/auth/widgets/register/personal_data_form.dart';
import 'package:ruteaflutter/features/auth/widgets/register/user_data_form.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final GlobalKey<FormBuilderState> _personalDataFormKey =
      GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _userDataFormKey =
      GlobalKey<FormBuilderState>();

  final PageController _pageController = PageController();

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
                  child: PersonalDataForm(formKey: _personalDataFormKey),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: UserDataForm(formKey: _userDataFormKey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
