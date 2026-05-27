import '../database/connection.dart';
import '../models/juego.dart';

class JuegosService {
  
  Future<List<Juego>> obtenerJuegos() async {

    final conexion = await DatabaseConnection.getConnection();

    try {
      final resultados = await conexion.query(
        'SELECT * FROM juegos ORDER BY nombre',
      );

      List<Juego> juegos = [];

      for (var row in resultados) {
        juegos.add(Juego.fromMap(row.fields));
      }

      return juegos;

    } finally {
      await conexion.close();
    }
    
  }

  Future<void> insertarJuego(Juego juego) async {

    final conexion = await DatabaseConnection.getConnection();

    try {
      await conexion.query(
        '''
        INSERT INTO juegos 
        (nombre, tipo, duracion_estimada_minutos, jugadores_min, jugadores_max, activo)
        VALUES (?, ?, ?, ?, ?, ?)
        ''',
        [
          juego.nombre,
          juego.tipo,
          juego.duracionEstimadaMinutos,
          juego.jugadoresMin,
          juego.jugadoresMax,
          juego.activo ? 1 : 0,
        ],
      );
    } finally {
      await conexion.close();
    }

  }
  
  Future<void> actualizarJuego(Juego juego) async {
    
    final conexion = await DatabaseConnection.getConnection();

    try {
      await conexion.query(
        '''
        UPDATE juegos
        SET nombre = ?,
            tipo = ?,
            duracion_estimada_minutos = ?,
            jugadores_min = ?,
            jugadores_max = ?,
            activo = ?
        WHERE id = ?
        ''',
        [
          juego.nombre,
          juego.tipo,
          juego.duracionEstimadaMinutos,
          juego.jugadoresMin,
          juego.jugadoresMax,
          juego.activo ? 1 : 0,
          juego.id,
        ],
      );
    } finally {
      await conexion.close();
    }

  }

}