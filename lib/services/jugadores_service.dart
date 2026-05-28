import '../database/connection.dart';
import '../models/jugador.dart';

class JugadoresService {
  Future<List<Jugador>> obtenerJugadores() async {
    final conexion = await DatabaseConnection.getConnection();

    try {
      final resultados = await conexion.query(
        'SELECT * FROM jugadores ORDER BY nombre',
      );

      List<Jugador> jugadores = [];

      for (var row in resultados) {
        jugadores.add(Jugador.fromMap(row.fields));
      }

      return jugadores;
    } finally {
      await conexion.close();
    }
  }
}