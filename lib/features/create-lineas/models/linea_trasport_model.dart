// models/linea_trasport_model.dart
// COPIA ESTE ARCHIVO EN: lib/features/create-lineas/models/linea_trasport_model.dart

class LineaTransporte {
  String numero;
  String color;
  String descripcion;
  bool estado;
  int idUserCreate;
  int idUserUpdate;

  LineaTransporte({
    required this.numero,
    required this.color,
    required this.descripcion,
    this.estado = true,
    this.idUserCreate = 0,
    this.idUserUpdate = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'color': color,
      'descripcion': descripcion,
      'estado': estado,
      'id_user_create': idUserCreate,
      'id_user_update': idUserUpdate,
    };
  }
}

class RutaTransporte {
  String numero;
  String color;
  String descripcion;
  bool estado;
  int idUserCreate;
  int idUserUpdate;

  RutaTransporte({
    required this.numero,
    required this.color,
    required this.descripcion,
    this.estado = true,
    this.idUserCreate = 0,
    this.idUserUpdate = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'color': color,
      'descripcion': descripcion,
      'estado': estado,
      'id_user_create': idUserCreate,
      'id_user_update': idUserUpdate,
    };
  }
}

class PuntoRuta {
  String nombre;
  String tipo;
  String latitud;
  String longitud;
  bool estado;
  double? distanciaAlSiguiente;
  int? orden; // Agregar orden
  int idUserCreate;
  int idUserUpdate;

  PuntoRuta({
    required this.nombre,
    required this.tipo,
    required this.latitud,
    required this.longitud,
    this.estado = true,
    this.distanciaAlSiguiente,
    this.orden,
    this.idUserCreate = 0,
    this.idUserUpdate = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'tipo': tipo,
      'latitud': latitud,
      'longitud': longitud,
      'estado': estado,
      'id_user_create': idUserCreate,
      'id_user_update': idUserUpdate,
      if (distanciaAlSiguiente != null)
        'distancia_al_siguiente': distanciaAlSiguiente,
      if (orden != null) 'orden': orden,
    };
  }
}

class RegistroLineaCompleto {
  LineaTransporte linea;
  RutaTransporte ruta;
  List<PuntoRuta> puntos;

  RegistroLineaCompleto({
    required this.linea,
    required this.ruta,
    required this.puntos,
  });

  Map<String, dynamic> toJson() {
    return {
      'linea': linea.toJson(),
      'ruta': ruta.toJson(),
      'puntos': puntos.map((p) => p.toJson()).toList(),
    };
  }
}
