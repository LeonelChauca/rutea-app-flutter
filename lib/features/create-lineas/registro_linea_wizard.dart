import 'package:flutter/material.dart';
import 'package:ruteaflutter/features/create-lineas/models/linea_trasport_model.dart';
import 'package:ruteaflutter/features/create-lineas/widgets/step1_linea_form.dart';
import 'package:ruteaflutter/features/create-lineas/widgets/step2_ruta_form.dart';
import 'package:ruteaflutter/features/create-lineas/widgets/step3_puntos_form.dart';
import 'dart:convert';

import 'package:ruteaflutter/features/create-lineas/widgets/step_indicator.dart';

class RegistroLineaWizard extends StatefulWidget {
  const RegistroLineaWizard({super.key});

  @override
  State<RegistroLineaWizard> createState() => _RegistroLineaWizardState();
}

class _RegistroLineaWizardState extends State<RegistroLineaWizard> {
  int _currentStep = 0;
  LineaTransporte? _lineaCreada;
  RutaTransporte? _rutaCreada;
  List<PuntoRuta> _puntosCreados = [];
  bool _isSubmitting = false;

  void _goToStep(int step) => setState(() => _currentStep = step);

  void _onLineaComplete(LineaTransporte linea) {
    setState(() {
      _lineaCreada = linea;
      _currentStep = 1;
    });
  }

  void _onRutaComplete(RutaTransporte ruta) {
    setState(() {
      _rutaCreada = ruta;
      _currentStep = 2;
    });
  }

  void _onPuntosComplete(List<PuntoRuta> puntos) {
    setState(() {
      _puntosCreados = puntos;
      _currentStep = 3;
    });
  }

  Future<void> _submitData() async {
    if (_lineaCreada == null || _rutaCreada == null || _puntosCreados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faltan datos para completar el registro'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final registroCompleto = RegistroLineaCompleto(
      linea: _lineaCreada!,
      ruta: _rutaCreada!,
      puntos: _puntosCreados,
    );

    final jsonData = registroCompleto.toJson();
    _showJsonPreview(jsonData, registroCompleto);
  }

  Future<void> _enviarAlBackend(RegistroLineaCompleto registro) async {
    setState(() => _isSubmitting = true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      final resultado = {
        'success': true,
        'message': 'Línea registrada exitosamente',
      };

      setState(() => _isSubmitting = false);
      if (!mounted) return;

      if (resultado['success'] == true) {
        Navigator.pop(context);
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (resultado['message'] ?? 'Error al registrar').toString(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showJsonPreview(
    Map<String, dynamic> jsonData,
    RegistroLineaCompleto registro,
  ) {
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vista Previa del JSON'),
        content: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              jsonString,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _enviarAlBackend(registro);
            },
            child: const Text('Enviar al Backend'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('¡Registro Completado!'),
          ],
        ),
        content: const Text(
          'La línea de transporte ha sido registrada exitosamente.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: Column(
        children: [
          if (_currentStep != 2)
            StepIndicator(currentStep: _currentStep, steps: defaultSteps),
          Expanded(child: _buildCurrentStep()),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return Step1LineaForm(
          lineaInicial: _lineaCreada,
          onContinue: _onLineaComplete,
        );
      case 1:
        return Step2RutaForm(
          lineaCreada: _lineaCreada!,
          rutaInicial: _rutaCreada,
          onContinue: _onRutaComplete,
          onBack: () => _goToStep(0),
        );
      case 2:
        return Step3PuntosForm(
          lineaCreada: _lineaCreada!,
          rutaCreada: _rutaCreada!,
          puntosIniciales: _puntosCreados.isEmpty ? null : _puntosCreados,
          onContinue: _onPuntosComplete,
          onBack: () => _goToStep(1),
        );
      case 3:
        return _buildResumenStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildResumenStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen del Registro',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Revisa la información antes de enviar',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          _buildSectionCard(
            title: 'Línea de Transporte',
            icon: Icons.directions_bus,
            color: _colorFromHex(_lineaCreada!.color),
            children: [
              _buildInfoRow('Número', _lineaCreada!.numero),
              _buildInfoRow('Descripción', _lineaCreada!.descripcion),
              _buildInfoRow('Color', _lineaCreada!.color),
            ],
            onEdit: () => _goToStep(0),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'Ruta',
            icon: Icons.route,
            color: _colorFromHex(_rutaCreada!.color),
            children: [
              _buildInfoRow('Número', _rutaCreada!.numero),
              _buildInfoRow('Descripción', _rutaCreada!.descripcion),
              _buildInfoRow('Color', _rutaCreada!.color),
            ],
            onEdit: () => _goToStep(1),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'Puntos de la Ruta',
            icon: Icons.location_on,
            color: Colors.orange,
            children: [
              _buildInfoRow('Total de puntos', '${_puntosCreados.length}'),
              const SizedBox(height: 12),
              ..._puntosCreados.asMap().entries.map((entry) {
                final index = entry.key;
                final punto = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _getColorForTipo(punto.tipo),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              punto.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${punto.tipo} • Lat: ${double.parse(punto.latitud).toStringAsFixed(4)}, Lng: ${double.parse(punto.longitud).toStringAsFixed(4)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            onEdit: () => _goToStep(2),
          ),

          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _goToStep(2),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back),
                      SizedBox(width: 8),
                      Text('Atrás'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Finalizar Registro'),
                      SizedBox(width: 8),
                      Icon(Icons.send),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
    required VoidCallback onEdit,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  color: color,
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFromHex(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  Color _getColorForTipo(String tipo) {
    switch (tipo) {
      case 'INICIO':
        return Colors.green;
      case 'FIN':
        return Colors.red;
      case 'PARADA':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}
