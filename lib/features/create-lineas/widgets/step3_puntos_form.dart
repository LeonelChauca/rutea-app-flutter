// widgets/step3_puntos_form.dart
// STEP 3 MEJORADO - Con líneas de ruta y snap a calles

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Importa el modelo - ajusta la ruta según tu estructura
import 'package:ruteaflutter/features/create-lineas/models/linea_trasport_model.dart';

class Step3PuntosForm extends StatefulWidget {
  final LineaTransporte lineaCreada;
  final RutaTransporte rutaCreada;
  final List<PuntoRuta>? puntosIniciales;
  final Function(List<PuntoRuta>) onContinue;
  final VoidCallback onBack;

  const Step3PuntosForm({
    super.key,
    required this.lineaCreada,
    required this.rutaCreada,
    this.puntosIniciales,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<Step3PuntosForm> createState() => _Step3PuntosFormState();
}

class _Step3PuntosFormState extends State<Step3PuntosForm> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  List<PuntoRuta> _puntos = [];
  List<LatLng> _routePolyline = []; // Línea de ruta entre puntos
  bool _isAddingPoint = false;
  bool _isLoadingRoute = false;
  String _selectedTipo = 'PARADA';
  StreamSubscription<Position>? _positionStreamSubscription;
  final TextEditingController _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.puntosIniciales != null) {
      _puntos = List.from(widget.puntosIniciales!);
      _recalcularRuta();
    }
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentPosition!, 15.0);
      }
    } catch (e) {
      debugPrint('Error obteniendo ubicación: $e');
    }
  }

  Color _colorFromHex(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  // Snap el punto a la calle más cercana usando OSRM
  Future<LatLng?> _snapToRoad(LatLng point) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/nearest/v1/driving/${point.longitude},${point.latitude}?number=1',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['code'] == 'Ok' && data['waypoints'].isNotEmpty) {
          final waypoint = data['waypoints'][0];
          final location = waypoint['location'];

          return LatLng(location[1] as double, location[0] as double);
        }
      }

      // Si falla, retornar el punto original
      return point;
    } catch (e) {
      debugPrint('Error en snap to road: $e');
      return point;
    }
  }

  // Obtener ruta entre dos puntos usando OSRM
  Future<List<LatLng>> _getRouteBetweenPoints(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      String coordinates =
          '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';

      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$coordinates?overview=full&geometries=geojson',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['code'] == 'Ok' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry']['coordinates'] as List;

          return geometry
              .map((coord) => LatLng(coord[1] as double, coord[0] as double))
              .toList();
        }
      }

      return [origin, destination];
    } catch (e) {
      debugPrint('Error obteniendo ruta: $e');
      return [origin, destination];
    }
  }

  // Recalcular toda la ruta cuando cambian los puntos
  Future<void> _recalcularRuta() async {
    if (_puntos.length < 2) {
      setState(() {
        _routePolyline = _puntos
            .map(
              (p) => LatLng(double.parse(p.latitud), double.parse(p.longitud)),
            )
            .toList();
      });
      return;
    }

    setState(() {
      _isLoadingRoute = true;
    });

    List<LatLng> fullRoute = [];

    for (int i = 0; i < _puntos.length - 1; i++) {
      final origin = LatLng(
        double.parse(_puntos[i].latitud),
        double.parse(_puntos[i].longitud),
      );
      final destination = LatLng(
        double.parse(_puntos[i + 1].latitud),
        double.parse(_puntos[i + 1].longitud),
      );

      final segment = await _getRouteBetweenPoints(origin, destination);

      if (i == 0) {
        fullRoute.addAll(segment);
      } else {
        fullRoute.addAll(segment.skip(1));
      }
    }

    if (mounted) {
      setState(() {
        _routePolyline = fullRoute;
        _isLoadingRoute = false;
      });
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) async {
    if (_isAddingPoint) {
      // Mostrar loading mientras hace snap
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Hacer snap al camino más cercano
      final snappedPoint = await _snapToRoad(point);

      if (!mounted) return;
      Navigator.pop(context); // Cerrar loading

      if (snappedPoint != null) {
        _showAddPointDialog(snappedPoint);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se encontró una calle cercana. Intenta en otro lugar.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _showAddPointDialog(LatLng point) {
    _nombreController.clear();
    _selectedTipo = 'PARADA';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white, // <--- Agrega esto
          surfaceTintColor: Colors.white,
          title: const Text('Agregar Punto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del punto *',
                    hintText: 'Ej: Plaza Murillo, Terminal',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tipo de punto',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedTipo,
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'PARADA', child: Text('Parada')),
                    DropdownMenuItem(value: 'INICIO', child: Text('Inicio')),
                    DropdownMenuItem(value: 'FIN', child: Text('Fin')),
                    DropdownMenuItem(
                      value: 'INTERMEDIO',
                      child: Text('Intermedio'),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedTipo = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Punto ajustado a la calle',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Lat: ${point.latitude.toStringAsFixed(6)}'),
                      Text('Lng: ${point.longitude.toStringAsFixed(6)}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nombreController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingresa un nombre')),
                  );
                  return;
                }

                final nuevoPunto = PuntoRuta(
                  nombre: _nombreController.text.trim(),
                  tipo: _selectedTipo,
                  latitud: point.latitude.toString(),
                  longitud: point.longitude.toString(),
                  estado: true,
                  idUserCreate: 1,
                  idUserUpdate: 1,
                );

                setState(() {
                  _puntos.add(nuevoPunto);
                  _isAddingPoint = false;
                });

                Navigator.pop(context);

                // Recalcular la ruta después de agregar punto
                await _recalcularRuta();
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _deletePunto(int index) async {
    setState(() {
      _puntos.removeAt(index);
    });
    await _recalcularRuta();
  }

  void _handleContinue() {
    if (_puntos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes agregar al menos un punto'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    widget.onContinue(_puntos);
  }

  IconData _getIconForTipo(String tipo) {
    switch (tipo) {
      case 'INICIO':
        return Icons.play_arrow;
      case 'FIN':
        return Icons.flag;
      case 'PARADA':
        return Icons.stop_circle;
      default:
        return Icons.location_on;
    }
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

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _nombreController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rutaColor = _colorFromHex(widget.rutaCreada.color);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: widget.onBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paso 3: Puntos de la Ruta',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Línea ${widget.lineaCreada.numero} - Ruta ${widget.rutaCreada.numero}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Mapa interactivo
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        _currentPosition ?? const LatLng(-16.5000, -68.1193),
                    initialZoom: 15.0,
                    onTap: _onMapTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),

                    // Línea de ruta segmentada
                    if (_routePolyline.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePolyline,
                            color: rutaColor.withOpacity(0.8),
                            strokeWidth: 5.0,
                            borderColor: Colors.white,
                            borderStrokeWidth: 2.0,
                          ),
                        ],
                      ),

                    MarkerLayer(
                      markers: [
                        // Marcadores de puntos agregados
                        ..._puntos.asMap().entries.map((entry) {
                          final index = entry.key;
                          final punto = entry.value;
                          final latLng = LatLng(
                            double.parse(punto.latitud),
                            double.parse(punto.longitud),
                          );
                          return Marker(
                            point: latLng,
                            width: 80,
                            height: 80,
                            child: GestureDetector(
                              onTap: () => _deletePunto(index),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: _getColorForTipo(punto.tipo),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      _getIconForTipo(punto.tipo),
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        // Marcador de ubicación actual
                        if (_currentPosition != null)
                          Marker(
                            point: _currentPosition!,
                            width: 40,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                // Botón para agregar punto
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton.extended(
                    heroTag: 'add_point',
                    onPressed: () {
                      setState(() {
                        _isAddingPoint = !_isAddingPoint;
                      });
                    },
                    backgroundColor: _isAddingPoint ? Colors.red : rutaColor,
                    icon: Icon(
                      _isAddingPoint ? Icons.close : Icons.add_location,
                    ),
                    label: Text(_isAddingPoint ? 'Cancelar' : 'Agregar Punto'),
                  ),
                ),

                // Loading de recalcular ruta
                if (_isLoadingRoute)
                  Positioned(
                    top: 80,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Calculando ruta...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Banner de instrucciones
                if (_isAddingPoint)
                  Positioned(
                    top: 80,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: rutaColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.touch_app, color: Colors.white),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Toca el mapa para agregar un punto en la calle',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Lista de puntos
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Puntos agregados (${_puntos.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_puntos.length >= 2)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.route,
                                size: 14,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Ruta trazada',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: _puntos.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay puntos agregados',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _puntos.length,
                          itemBuilder: (context, index) {
                            final punto = _puntos[index];
                            return Container(
                              width: 150,
                              margin: const EdgeInsets.only(right: 12),
                              child: Card(
                                elevation: 2,
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: _getColorForTipo(
                                                punto.tipo,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '${index + 1}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 18,
                                            ),
                                            color: Colors.red,
                                            onPressed: () =>
                                                _deletePunto(index),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        punto.nombre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        punto.tipo,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Botón continuar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: rutaColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuar al Resumen',
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
          ),
        ],
      ),
    );
  }
}
