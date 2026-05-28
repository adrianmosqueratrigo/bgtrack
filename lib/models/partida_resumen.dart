class PartidaResumen {
  int id;
  String nombreJuego;
  DateTime fechaHora;
  int? duracionMinutos;
  String estado;
  String? ganadores;
  int numeroJugadores;

  PartidaResumen({
    required this.id,
    required this.nombreJuego,
    required this.fechaHora,
    this.duracionMinutos,
    required this.estado,
    this.ganadores,
    required this.numeroJugadores,
    
  });

  factory PartidaResumen.fromMap(Map<String, dynamic> map) {
    return PartidaResumen(
      id: map['id'],
      nombreJuego: map['nombre_juego'],
      fechaHora: DateTime.parse(map['fecha_hora'].toString()),
      duracionMinutos: map['duracion_minutos'],
      estado: map['estado'],
      ganadores: map['ganadores']?.toString(),
      numeroJugadores: map['numero_jugadores'],
    );
  }
}