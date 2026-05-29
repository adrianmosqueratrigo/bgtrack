class EstadisticasGenerales {
  int totalPartidas;
  int partidasFinalizadas;
  int partidasCanceladas;
  String juegoMasJugado;
  String jugadorMasVictorias;
  int victoriasJugadorMasVictorias;
  int partidasJugadorMasVictorias;
  String jugadorMejorRatio;
  double mejorRatioVictorias;
  double partidasMediasPorJugador;
  double duracionMediaMinutos;

  EstadisticasGenerales({
    required this.totalPartidas,
    required this.partidasFinalizadas,
    required this.partidasCanceladas,
    required this.juegoMasJugado,
    required this.jugadorMasVictorias,
    required this.victoriasJugadorMasVictorias,
    required this.partidasJugadorMasVictorias,
    required this.jugadorMejorRatio,
    required this.mejorRatioVictorias,
    required this.partidasMediasPorJugador,
    required this.duracionMediaMinutos,
  });
}