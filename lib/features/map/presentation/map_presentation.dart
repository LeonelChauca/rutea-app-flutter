import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapPresentation extends StatefulWidget {
  const MapPresentation({super.key});

  @override
  State<MapPresentation> createState() => _MapPresentationState();
}

class _MapPresentationState extends State<MapPresentation> {
  LatLng? _currentPosition;
  final MapController _mapController = MapController();
  bool _isLoading = true;

  // Para origen y destino
  LatLng? _originPoint;
  LatLng? _destinationPoint;
  List<LatLng> _routePoints = [];
  bool _isCalculatingRoute = false;

  // Controladores para los inputs
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  bool _selectingOrigin = false;
  bool _selectingDestination = false;

  // 🔹 CRÍTICO: Suscripción para el stream de ubicación
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startLocationUpdates();
  }

  // 🔹 IMPORTANTE: Método seguro para setState
  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _safeSetState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _safeSetState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _safeSetState(() => _isLoading = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      _safeSetState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      if (mounted) {
        _mapController.move(_currentPosition!, 18.0);
      }
    } catch (e) {
      debugPrint('Error obteniendo ubicación: $e');
      _safeSetState(() => _isLoading = false);
    }
  }

  // 🔹 ARREGLADO: Ahora guarda la suscripción
  void _startLocationUpdates() {
    _positionStreamSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen(
          (Position position) {
            _safeSetState(() {
              _currentPosition = LatLng(position.latitude, position.longitude);
            });
          },
          onError: (error) {
            debugPrint('Error en stream de ubicación: $error');
          },
        );
  }

  // Obtener ruta siguiendo calles usando OSRM
  Future<List<LatLng>> _getRouteFromOSRM(
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

      return [];
    } catch (e) {
      debugPrint('Error obteniendo ruta: $e');
      return [];
    }
  }

  // Manejar toques en el mapa
  Future<void> _onMapTap(TapPosition tapPosition, LatLng point) async {
    // Si está seleccionando origen
    if (_selectingOrigin) {
      _safeSetState(() {
        _originPoint = point;
        _originController.text =
            'Lat: ${point.latitude.toStringAsFixed(4)}, Lng: ${point.longitude.toStringAsFixed(4)}';
        _selectingOrigin = false;
      });

      // Si ya hay destino, calcular ruta
      if (_destinationPoint != null) {
        _safeSetState(() => _isCalculatingRoute = true);
        final route = await _getRouteFromOSRM(
          _originPoint!,
          _destinationPoint!,
        );
        _safeSetState(() {
          _routePoints = route;
          _isCalculatingRoute = false;
        });
      }
      return;
    }

    // Si está seleccionando destino
    if (_selectingDestination) {
      _safeSetState(() {
        _destinationPoint = point;
        _destinationController.text =
            'Lat: ${point.latitude.toStringAsFixed(4)}, Lng: ${point.longitude.toStringAsFixed(4)}';
        _selectingDestination = false;
      });

      // Si ya hay origen, calcular ruta
      if (_originPoint != null) {
        _safeSetState(() => _isCalculatingRoute = true);
        final route = await _getRouteFromOSRM(
          _originPoint!,
          _destinationPoint!,
        );
        _safeSetState(() {
          _routePoints = route;
          _isCalculatingRoute = false;
        });
      }
      return;
    }
  }

  // 🔹 CRÍTICO: Implementar dispose correctamente
  @override
  void dispose() {
    // Cancelar la suscripción del stream de ubicación
    _positionStreamSubscription?.cancel();

    // Dispose de los controladores de texto
    _originController.dispose();
    _destinationController.dispose();

    // Dispose del controlador del mapa
    _mapController.dispose();

    // Siempre llamar super.dispose() al final
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  _currentPosition ?? const LatLng(-16.5000, -68.1193),
              initialZoom: 18.0,
              minZoom: 3.0,
              maxZoom: 19.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.ruteaflutter',
              ),

              // Línea de la ruta
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: Colors.blue,
                      strokeWidth: 5.0,
                    ),
                  ],
                ),

              // Marcadores de origen y destino
              MarkerLayer(
                markers: [
                  // Marcador de origen
                  if (_originPoint != null)
                    Marker(
                      point: _originPoint!,
                      width: 50,
                      height: 50,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            width: 40,
                            height: 40,
                            child: const Center(
                              child: Icon(
                                Icons.trip_origin,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Marcador de destino
                  if (_destinationPoint != null)
                    Marker(
                      point: _destinationPoint!,
                      width: 50,
                      height: 50,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            width: 40,
                            height: 40,
                            child: const Center(
                              child: Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Marcador de ubicación actual
                  if (_currentPosition != null)
                    Marker(
                      point: _currentPosition!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                ],
              ),

              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),

          // Indicador de carga
          if (_isLoading || _isCalculatingRoute)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    if (_isCalculatingRoute)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                          'Calculando ruta...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Panel de inputs
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Card(
              color: Colors.white,
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input de Origen
                    TextField(
                      controller: _originController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Origen',
                        hintText: 'Selecciona el punto de origen',
                        prefixIcon: const Icon(
                          Icons.trip_origin,
                          color: Colors.green,
                        ),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _selectingOrigin
                                ? Icons.cancel
                                : Icons.add_location,
                            color: _selectingOrigin ? Colors.red : Colors.green,
                          ),
                          onPressed: () {
                            _safeSetState(() {
                              _selectingOrigin = !_selectingOrigin;
                              _selectingDestination = false;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Input de Destino
                    TextField(
                      controller: _destinationController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Destino',
                        hintText: 'Selecciona el punto de destino',
                        prefixIcon: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                        ),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _selectingDestination
                                ? Icons.cancel
                                : Icons.add_location,
                            color: _selectingDestination
                                ? Colors.red
                                : Colors.green,
                          ),
                          onPressed: () {
                            _safeSetState(() {
                              _selectingDestination = !_selectingDestination;
                              _selectingOrigin = false;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Mensajes de ayuda
                    if (_selectingOrigin)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.touch_app,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Toca el mapa para seleccionar el origen',
                                style: TextStyle(
                                  color: Colors.green.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_selectingDestination)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.touch_app,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Toca el mapa para seleccionar el destino',
                                style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Botón flotante para centrar en ubicación
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'location',
              onPressed: () {
                if (_currentPosition != null && mounted) {
                  _mapController.move(_currentPosition!, 18.0);
                }
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
