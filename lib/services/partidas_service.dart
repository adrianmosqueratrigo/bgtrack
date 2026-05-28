import '../database/connection.dart';
import '../models/participante_partida.dart';
import '../models/partida_detalle.dart';
import '../models/partida_resumen.dart';

class PartidasService {
  Future<List<PartidaResumen>> obtenerPartidas() async {
    final conexion = await DatabaseConnection.getConnection();

    try {
      final resultados = await conexion.query(
        '''
        SELECT 
            p.id,
            j.nombre AS nombre_juego,
            p.fecha_hora,
            p.duracion_minutos,
            p.estado,
            COUNT(DISTINCT pa.id_jugador) AS numero_jugadores,
            CAST(
              GROUP_CONCAT(
                  CASE 
                      WHEN pa.es_ganador = 1 THEN ju.nombre
                      ELSE NULL
                  END
                  SEPARATOR ', '
              ) AS CHAR
            ) AS ganadores
        FROM partidas p
        INNER JOIN juegos j ON p.id_juego = j.id
        LEFT JOIN participaciones pa ON p.id = pa.id_partida
        LEFT JOIN jugadores ju ON pa.id_jugador = ju.id
        GROUP BY p.id, j.nombre, p.fecha_hora, p.duracion_minutos, p.estado
        ORDER BY p.fecha_hora DESC
        ''',
      );

      List<PartidaResumen> partidas = [];

      for (var row in resultados) {
        partidas.add(PartidaResumen.fromMap(row.fields));
      }

      return partidas;
    } finally {
      await conexion.close();
    }
  }

  Future<PartidaDetalle?> obtenerDetallePartida(int idPartida) async {
    final conexion = await DatabaseConnection.getConnection();

    try {
      final resultados = await conexion.query(
        '''
        SELECT 
            p.id,
            j.nombre AS nombre_juego,
            u.username AS username_usuario,
            p.fecha_hora,
            p.duracion_minutos,
            p.estado,
            p.notas
        FROM partidas p
        INNER JOIN juegos j ON p.id_juego = j.id
        INNER JOIN usuarios u ON p.id_usuario = u.id
        WHERE p.id = ?
        ''',
        [idPartida],
      );

      if (resultados.isEmpty) {
        return null;
      }

      return PartidaDetalle.fromMap(resultados.first.fields);
    } finally {
      await conexion.close();
    }
  }

  Future<List<ParticipantePartida>> obtenerParticipantesPartida(
    int idPartida,
  ) async {
    final conexion = await DatabaseConnection.getConnection();

    try {
      final resultados = await conexion.query(
        '''
        SELECT
            ju.nombre AS nombre_jugador,
            pa.puntuacion,
            pa.es_ganador
        FROM participaciones pa
        INNER JOIN jugadores ju ON pa.id_jugador = ju.id
        WHERE pa.id_partida = ?
        ORDER BY pa.es_ganador DESC, ju.nombre
        ''',
        [idPartida],
      );

      List<ParticipantePartida> participantes = [];

      for (var row in resultados) {
        participantes.add(ParticipantePartida.fromMap(row.fields));
      }

      return participantes;
    } finally {
      await conexion.close();
    }
  }

  Future<void> actualizarPartidaBasica({
    required int idPartida,
    required DateTime fechaHora,
    int? duracionMinutos,
    required String estado,
    String? notas,
  }) async {
    final conexion = await DatabaseConnection.getConnection();

    try {
      await conexion.query(
        '''
        UPDATE partidas
        SET fecha_hora = ?,
            duracion_minutos = ?,
            estado = ?,
            notas = ?
        WHERE id = ?
        ''',
        [
          fechaHora.toIso8601String().replaceFirst('T', ' ').substring(0, 19),
          duracionMinutos,
          estado,
          notas,
          idPartida,
        ],
      );
    } finally {
      await conexion.close();
    }
  }

}