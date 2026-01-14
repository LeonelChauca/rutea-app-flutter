import 'package:flutter/material.dart';
import 'package:ruteaflutter/features/create-lineas/models/linea_trasport_model.dart';

class Step1LineaForm extends StatefulWidget {
  final LineaTransporte? lineaInicial;
  final Function(LineaTransporte) onContinue;

  const Step1LineaForm({
    super.key,
    this.lineaInicial,
    required this.onContinue,
  });

  @override
  State<Step1LineaForm> createState() => _Step1LineaFormState();
}

class _Step1LineaFormState extends State<Step1LineaForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numeroController;
  late TextEditingController _descripcionController;
  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _numeroController = TextEditingController(
      text: widget.lineaInicial?.numero ?? '',
    );
    _descripcionController = TextEditingController(
      text: widget.lineaInicial?.descripcion ?? '',
    );
    if (widget.lineaInicial?.color != null) {
      _selectedColor = _colorFromHex(widget.lineaInicial!.color);
    }
  }

  Color _colorFromHex(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      final linea = LineaTransporte(
        numero: _numeroController.text.trim(),
        color: _colorToHex(_selectedColor),
        descripcion: _descripcionController.text.trim(),
        estado: true,
        idUserCreate: 1, // Cambiar por el ID del usuario actual
        idUserUpdate: 1,
      );
      widget.onContinue(linea);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            const Text(
              'Paso 1: Registro de Línea',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresa la información básica de la línea de transporte',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),

            // Número de línea
            TextFormField(
              controller: _numeroController,
              decoration: InputDecoration(
                labelText: 'Número de Línea *',
                hintText: 'Ej: M-1, 211, etc.',
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El número de línea es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Descripción
            TextFormField(
              controller: _descripcionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descripción *',
                hintText: 'Describe el recorrido o características de la línea',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La descripción es obligatoria';
                }
                if (value.trim().length < 10) {
                  return 'La descripción debe tener al menos 10 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Selector de color
            const Text(
              'Color de la Línea *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  // Color seleccionado
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Color seleccionado',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              _colorToHex(_selectedColor),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Paleta de colores
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        [
                          Colors.red,
                          Colors.blue,
                          Colors.green,
                          Colors.orange,
                          Colors.purple,
                          Colors.teal,
                          Colors.pink,
                          Colors.amber,
                          Colors.indigo,
                          Colors.cyan,
                          Colors.lime,
                          Colors.brown,
                        ].map((color) {
                          final isSelected = _selectedColor == color;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey.shade400,
                                  width: isSelected ? 3 : 1,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 30,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Botón continuar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
