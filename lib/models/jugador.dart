class Jugador {
  int? id;
  String nombre;
  DateTime? fechaNacimiento;
  String? residencia;
  DateTime? fechaAlta;
  bool activo;

  Jugador({
    this.id,
    required this.nombre,
    this.fechaNacimiento,
    this.residencia,
    this.fechaAlta,
    this.activo = true,
  });

  factory Jugador.fromMap(Map<String, dynamic> map) {
    return Jugador(
      id: map['id'],
      nombre: map['nombre'],
      fechaNacimiento: map['fecha_nacimiento'] != null
          ? DateTime.parse(map['fecha_nacimiento'].toString())
          : null,
      residencia: map['residencia'],
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
      'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
      'residencia': residencia,
      'fecha_alta': fechaAlta?.toIso8601String(),
      'activo': activo ? 1 : 0,
    };
  }
}
