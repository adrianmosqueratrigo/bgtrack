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

  Future<void> insertarJugador(Jugador jugador) async {
    final conexion = await DatabaseConnection.getConnection();

    try {
      await conexion.query(
        '''
        INSERT INTO jugadores
        (nombre, fecha_nacimiento, residencia, activo)
        VALUES (?, ?, ?, ?)
        ''',
        [
          jugador.nombre,
          jugador.fechaNacimiento?.toIso8601String().split('T')[0],
          jugador.residencia,
          jugador.activo ? 1 : 0,
        ],
      );
    } finally {
      await conexion.close();
    }
  }

}