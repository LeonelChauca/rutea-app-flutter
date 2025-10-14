import 'package:flutter/material.dart';

class SearchInputs extends StatelessWidget {
  const SearchInputs({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _SearchField(
          hint: 'Seleccione origen',
          icon: Icons.radio_button_checked,
        ),
        SizedBox(height: 8),
        _SearchField(hint: 'Seleccione destino', icon: Icons.place),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final String hint;
  final IconData icon;

  const _SearchField({required this.hint, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
