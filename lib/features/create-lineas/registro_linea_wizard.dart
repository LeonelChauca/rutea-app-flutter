import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ruteaflutter/features/create-lineas/models/linea_trasport_model.dart';
import 'package:ruteaflutter/features/create-lineas/widgets/step1_linea_form.dart';
import 'package:ruteaflutter/features/create-lineas/widgets/step2_ruta_form.dart';
import 'package:ruteaflutter/features/create-lineas/widgets/step3_puntos_form.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ruteaflutter/services/api.dart';
import 'package:ruteaflutter/services/rutas/rutas.service.dart';

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
  late final RutasService _rutasService = RutasService(Api.dio);

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

  /// Calcula la distancia real en km entre dos coordenadas usando OSRM.
  /// Si falla la petición, hace fallback a Geolocator.distanceBetween.
  Future<double> _calcularDistanciaEntrePuntos(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) async {
    try {
      final coordinates = '$lon1,$lat1;$lon2,$lat2';
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$coordinates?overview=false',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['code'] == 'Ok' && (data['routes'] as List).isNotEmpty) {
          final route = (data['routes'] as List).first as Map<String, dynamic>;
          final distanceMeters = route['distance'] as num;
          return distanceMeters / 1000.0;
        }
      }
    } catch (_) {
      // En caso de error, se usa el cálculo geodésico como respaldo.
    }

    final distanciaMetros = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    return distanciaMetros / 1000.0;
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

    // 1. Crear la lista de puntos con distancias calculadas (en km)
    List<PuntoRuta> puntosFinales = [];

    for (int i = 0; i < _puntosCreados.length; i++) {
      double? distancia;

      // 2. Si hay un punto siguiente, calculamos la distancia
      if (i < _puntosCreados.length - 1) {
        final lat1 = double.tryParse(_puntosCreados[i].latitud);
        final lon1 = double.tryParse(_puntosCreados[i].longitud);
        final lat2 = double.tryParse(_puntosCreados[i + 1].latitud);
        final lon2 = double.tryParse(_puntosCreados[i + 1].longitud);

        if (lat1 != null && lon1 != null && lat2 != null && lon2 != null) {
          final distanciaKm =
              await _calcularDistanciaEntrePuntos(lat1, lon1, lat2, lon2);
          distancia = double.parse(distanciaKm.toStringAsFixed(2));
        } else {
          distancia = null;
        }
      } else {
        // Último punto: distancia al siguiente = 0.0 km
        distancia = 0.0;
      }

      // 3. Crear el objeto PuntoRuta con los datos adicionales
      final punto = PuntoRuta(
        nombre: _puntosCreados[i].nombre,
        tipo: _puntosCreados[i].tipo.toLowerCase(),
        latitud: _puntosCreados[i].latitud,
        longitud: _puntosCreados[i].longitud,
        estado: true,
        orden: i + 1,
        distanciaAlSiguiente: distancia,
        idUserCreate: 7,
        idUserUpdate: 0,
      );

      puntosFinales.add(punto);
    }

    // 4. Crear el objeto completo
    final registroCompleto = RegistroLineaCompleto(
      linea: _lineaCreada!,
      ruta: _rutaCreada!,
      puntos: puntosFinales, // Usar la lista con distancias calculadas
    );

    // 5. Enviar al backend
    await _enviarAlBackend(registroCompleto);
  }

  Future<void> _enviarAlBackend(RegistroLineaCompleto registro) async {
    setState(() => _isSubmitting = true);

    try {
      await _rutasService.registerRuta(registro);

      setState(() => _isSubmitting = false);
      if (!mounted) return;

      Navigator.pop(context);
      _showSuccessDialog();
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocurrió un error al registrar la ruta'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                  onPressed: _isSubmitting ? null : _submitData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Enviando...'),
                          ],
                        )
                      : const Row(
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
      color: Colors.white,
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
