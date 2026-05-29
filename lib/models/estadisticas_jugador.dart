class EstadisticasJugador {
  int totalPartidas;
  int partidasFinalizadas;
  int partidasCanceladas;
  String juegoMasJugado;
  int totalVictorias;
  double ratioVictorias;
  double duracionMediaMinutos;

  EstadisticasJugador({
    required this.totalPartidas,
    required this.partidasFinalizadas,
    required this.partidasCanceladas,
    required this.juegoMasJugado,
    required this.totalVictorias,
    required this.ratioVictorias,
    required this.duracionMediaMinutos,
  });
}