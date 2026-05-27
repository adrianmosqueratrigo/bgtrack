class Juego {
  int? id;
  String nombre;
  String? tipo;
  int? duracionEstimadaMinutos;
  int jugadoresMin;
  int jugadoresMax;
  DateTime? fechaAlta;
  bool activo;

  Juego({
    this.id,
    required this.nombre,
    this.tipo,
    this.duracionEstimadaMinutos,
    required this.jugadoresMin,
    required this.jugadoresMax,
    this.fechaAlta,
    this.activo = true,
  });

  factory Juego.fromMap(Map<String, dynamic> map) {
    return Juego(
      id: map['id'],
      nombre: map['nombre'],
      tipo: map['tipo'],
      duracionEstimadaMinutos: map['duracion_estimada_minutos'],
      jugadoresMin: map['jugadores_min'],
      jugadoresMax: map['jugadores_max'],
      fechaAlta: map['fecha_alta'] != null
          ? DateTime.parse(map['fecha_alta'].toString())
          : null,
      activo: map['activo'] == 1 || map['activo'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'duracion_estimada_minutos': duracionEstimadaMinutos,
      'jugadores_min': jugadoresMin,
      'jugadores_max': jugadoresMax,
      'fecha_alta': fechaAlta?.toIso8601String(),
      'activo': activo ? 1 : 0,
    };
  }
}
