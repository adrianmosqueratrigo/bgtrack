class Participacion {
  int? id;
  int idPartida;
  int idJugador;
  int? puntuacion;
  bool esGanador;

  Participacion({
    this.id,
    required this.idPartida,
    required this.idJugador,
    this.puntuacion,
    this.esGanador = false,
  });

  factory Participacion.fromMap(Map<String, dynamic> map) {
    return Participacion(
      id: map['id'],
      idPartida: map['id_partida'],
      idJugador: map['id_jugador'],
      puntuacion: map['puntuacion'],
      esGanador: map['es_ganador'] == 1 || map['es_ganador'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_partida': idPartida,
      'id_jugador': idJugador,
      'puntuacion': puntuacion,
      'es_ganador': esGanador ? 1 : 0,
    };
  }
}
