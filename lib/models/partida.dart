class Partida {
  int? id;
  int idJuego;
  int idUsuario;
  DateTime fechaHora;
  int? duracionMinutos;
  String estado;
  String? notas;

  Partida({
    this.id,
    required this.idJuego,
    required this.idUsuario,
    required this.fechaHora,
    this.duracionMinutos,
    required this.estado,
    this.notas,
  });

  factory Partida.fromMap(Map<String, dynamic> map) {
    return Partida(
      id: map['id'],
      idJuego: map['id_juego'],
      idUsuario: map['id_usuario'],
      fechaHora: DateTime.parse(map['fecha_hora'].toString()),
      duracionMinutos: map['duracion_minutos'],
      estado: map['estado'],
      notas: map['notas'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_juego': idJuego,
      'id_usuario': idUsuario,
      'fecha_hora': fechaHora.toIso8601String(),
      'duracion_minutos': duracionMinutos,
      'estado': estado,
      'notas': notas,
    };
  }
}
