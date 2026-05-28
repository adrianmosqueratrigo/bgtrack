class ParticipantePartida {
  String nombreJugador;
  int? puntuacion;
  bool esGanador;

  ParticipantePartida({
    required this.nombreJugador,
    this.puntuacion,
    required this.esGanador,
  });

  factory ParticipantePartida.fromMap(Map<String, dynamic> map) {
    return ParticipantePartida(
      nombreJugador: map['nombre_jugador'],
      puntuacion: map['puntuacion'],
      esGanador: map['es_ganador'] == 1 || map['es_ganador'] == true,
    );
  }
}