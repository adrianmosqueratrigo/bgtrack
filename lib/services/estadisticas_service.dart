import '../database/connection.dart';
import '../models/estadisticas_generales.dart';
import '../models/estadisticas_juego.dart';
import '../models/estadisticas_jugador.dart';
import '../models/juego.dart';
import '../models/jugador.dart';

class EstadisticasService {
  int convertirEntero(dynamic valor) {
    if (valor == null) {
      return 0;
    }

    if (valor is int) {
      return valor;
    }

    if (valor is double) {
      return valor.toInt();
    }

    return int.tryParse(valor.toString()) ?? 0;
  }

  double convertirDecimal(dynamic valor) {
    if (valor == null) {
      return 0;
    }

    if (valor is double) {
      return valor;
    }

    if (valor is int) {
      return valor.toDouble();
    }

    return double.tryParse(valor.toString()) ?? 0;
  }


  Future<EstadisticasGenerales> obtenerEstadisticasGenerales() async {
    final conexion = await DatabaseConnection.getConnection();

    try {
      final resultadoTotales = await conexion.query('''
        SELECT
          COUNT(*) AS total_partidas,
          SUM(CASE WHEN estado = 'finalizada' THEN 1 ELSE 0 END) AS finalizadas,
          SUM(CASE WHEN estado = 'cancelada' THEN 1 ELSE 0 END) AS canceladas
        FROM partidas
        ''');

      final filaTotales = resultadoTotales.first.fields;

      final resultadoJuegoMasJugado = await conexion.query('''
        SELECT j.nombre AS nombre_juego, COUNT(p.id) AS total
        FROM partidas p
        INNER JOIN juegos j ON p.id_juego = j.id
        GROUP BY j.id, j.nombre
        ORDER BY total DESC
        LIMIT 1
        ''');

      final resultadoJugadorMasVictorias = await conexion.query(
        '''
        SELECT 
          ju.id AS id_jugador,
          ju.nombre AS nombre_jugador,
          COUNT(*) AS total_victorias
        FROM participaciones pa
        INNER JOIN jugadores ju ON pa.id_jugador = ju.id
        WHERE pa.es_ganador = 1
        GROUP BY ju.id, ju.nombre
        ORDER BY total_victorias DESC
        LIMIT 1
        ''',
      );

      final resultadoJugadorMejorRatio = await conexion.query('''
        SELECT
          ju.nombre AS nombre_jugador,
          COUNT(pa.id_partida) AS partidas_jugadas,
          SUM(CASE WHEN pa.es_ganador = 1 THEN 1 ELSE 0 END) AS victorias,
          SUM(CASE WHEN pa.es_ganador = 1 THEN 1 ELSE 0 END) / COUNT(pa.id_partida) AS ratio_victoria
        FROM participaciones pa
        INNER JOIN jugadores ju ON pa.id_jugador = ju.id
        GROUP BY ju.id, ju.nombre
        HAVING partidas_jugadas > 0
        ORDER BY ratio_victoria DESC, victorias DESC, partidas_jugadas DESC
        LIMIT 1
        ''');

      final resultadoPartidasMedias = await conexion.query('''
        SELECT
          COUNT(*) / COUNT(DISTINCT id_jugador) AS media_partidas
        FROM participaciones
        ''');

      final resultadoDuracionMedia = await conexion.query('''
        SELECT AVG(duracion_minutos) AS duracion_media
        FROM partidas
        WHERE duracion_minutos IS NOT NULL
        ''');

      final totalPartidas = convertirEntero(filaTotales['total_partidas']);
      final partidasFinalizadas = convertirEntero(filaTotales['finalizadas']);
      final partidasCanceladas = convertirEntero(filaTotales['canceladas']);

      final juegoMasJugado = resultadoJuegoMasJugado.isEmpty
          ? 'Sin datos'
          : resultadoJuegoMasJugado.first.fields['nombre_juego'].toString();

      final jugadorMasVictorias = resultadoJugadorMasVictorias.isEmpty
          ? 'Sin datos'
          : resultadoJugadorMasVictorias.first.fields['nombre_jugador']
                .toString();
      
      int victoriasJugadorMasVictorias = 0;
      int partidasJugadorMasVictorias = 0;

      if (resultadoJugadorMasVictorias.isNotEmpty) {
        final filaJugadorMasVictorias = resultadoJugadorMasVictorias.first.fields;

        victoriasJugadorMasVictorias = convertirEntero(
          filaJugadorMasVictorias['total_victorias'],
        );

        final idJugadorMasVictorias = convertirEntero(
          filaJugadorMasVictorias['id_jugador'],
        );

        final resultadoPartidasJugadorMasVictorias = await conexion.query(
          '''
          SELECT COUNT(*) AS total_partidas_jugador
          FROM participaciones
          WHERE id_jugador = ?
          ''',
          [idJugadorMasVictorias],
        );

        partidasJugadorMasVictorias = convertirEntero(
          resultadoPartidasJugadorMasVictorias
              .first
              .fields['total_partidas_jugador'],
        );
      }

      final jugadorMejorRatio = resultadoJugadorMejorRatio.isEmpty
          ? 'Sin datos'
          : resultadoJugadorMejorRatio.first.fields['nombre_jugador']
                .toString();

      final mejorRatioVictorias = resultadoJugadorMejorRatio.isEmpty
          ? 0.0
          : convertirDecimal(
              resultadoJugadorMejorRatio.first.fields['ratio_victoria'],
            );

      final partidasMediasValor =
          resultadoPartidasMedias.first.fields['media_partidas'];

      final duracionMediaValor =
          resultadoDuracionMedia.first.fields['duracion_media'];

      return EstadisticasGenerales(
        totalPartidas: totalPartidas,
        partidasFinalizadas: partidasFinalizadas,
        partidasCanceladas: partidasCanceladas,
        juegoMasJugado: juegoMasJugado,
        jugadorMasVictorias: jugadorMasVictorias,
        victoriasJugadorMasVictorias: victoriasJugadorMasVictorias,
        partidasJugadorMasVictorias: partidasJugadorMasVictorias,
        jugadorMejorRatio: jugadorMejorRatio,
        mejorRatioVictorias: mejorRatioVictorias,
        partidasMediasPorJugador: convertirDecimal(partidasMediasValor),
        duracionMediaMinutos: convertirDecimal(duracionMediaValor),
      );
    } finally {
      await conexion.close();
    }
  }

  Future<List<Jugador>> obtenerJugadoresConPartidas() async {
    final conexion = await DatabaseConnection.getConnection();

    try {
      final resultados = await conexion.query(
        '''
        SELECT DISTINCT ju.*
        FROM jugadores ju
        INNER JOIN participaciones pa ON ju.id = pa.id_jugador
        ORDER BY ju.nombre
        ''',
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


  Future<EstadisticasJugador> obtenerEstadisticasJugador(int idJugador) async {
    final conexion = await DatabaseConnection.getConnection();

    try {
      final resultadoTotales = await conexion.query(
        '''
        SELECT
          COUNT(DISTINCT p.id) AS total_partidas,
          SUM(CASE WHEN p.estado = 'finalizada' THEN 1 ELSE 0 END) AS finalizadas,
          SUM(CASE WHEN p.estado = 'cancelada' THEN 1 ELSE 0 END) AS canceladas,
          SUM(CASE WHEN pa.es_ganador = 1 THEN 1 ELSE 0 END) AS victorias,
          AVG(p.duracion_minutos) AS duracion_media
        FROM participaciones pa
        INNER JOIN partidas p ON pa.id_partida = p.id
        WHERE pa.id_jugador = ?
        ''',
        [idJugador],
      );

      final filaTotales = resultadoTotales.first.fields;

      final resultadoJuegoMasJugado = await conexion.query(
        '''
        SELECT j.nombre AS nombre_juego, COUNT(*) AS total
        FROM participaciones pa
        INNER JOIN partidas p ON pa.id_partida = p.id
        INNER JOIN juegos j ON p.id_juego = j.id
        WHERE pa.id_jugador = ?
        GROUP BY j.id, j.nombre
        ORDER BY total DESC
        LIMIT 1
        ''',
        [idJugador],
      );

      final totalPartidas = convertirEntero(filaTotales['total_partidas']);
      final partidasFinalizadas = convertirEntero(filaTotales['finalizadas']);
      final partidasCanceladas = convertirEntero(filaTotales['canceladas']);
      final totalVictorias = convertirEntero(filaTotales['victorias']);
      final duracionMediaMinutos = convertirDecimal(
        filaTotales['duracion_media'],
      );

      final juegoMasJugado = resultadoJuegoMasJugado.isEmpty
          ? 'Sin datos'
          : resultadoJuegoMasJugado.first.fields['nombre_juego'].toString();

      final ratioVictorias = totalPartidas == 0
          ? 0.0
          : totalVictorias / totalPartidas;

      return EstadisticasJugador(
        totalPartidas: totalPartidas,
        partidasFinalizadas: partidasFinalizadas,
        partidasCanceladas: partidasCanceladas,
        juegoMasJugado: juegoMasJugado,
        totalVictorias: totalVictorias,
        ratioVictorias: ratioVictorias,
        duracionMediaMinutos: duracionMediaMinutos,
      );
    } finally {
      await conexion.close();
    }
  }


Future<List<Juego>> obtenerJuegosConPartidas() async {
  final conexion = await DatabaseConnection.getConnection();

  try {
    final resultados = await conexion.query(
      '''
      SELECT DISTINCT j.*
      FROM juegos j
      INNER JOIN partidas p ON j.id = p.id_juego
      ORDER BY j.nombre
      ''',
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

Future<EstadisticasJuego> obtenerEstadisticasJuego(int idJuego) async {
  final conexion = await DatabaseConnection.getConnection();

  try {
    final resultadoTotales = await conexion.query(
      '''
      SELECT 
        COUNT(*) AS total_partidas,
        AVG(duracion_minutos) AS duracion_media
      FROM partidas
      WHERE id_juego = ?
      ''',
      [idJuego],
    );

    final filaTotales = resultadoTotales.first.fields;

    final resultadoJugadorMasVictorias = await conexion.query(
      '''
      SELECT 
        ju.id AS id_jugador,
        ju.nombre AS nombre_jugador,
        COUNT(*) AS total_victorias
      FROM participaciones pa
      INNER JOIN partidas p ON pa.id_partida = p.id
      INNER JOIN jugadores ju ON pa.id_jugador = ju.id
      WHERE p.id_juego = ?
        AND pa.es_ganador = 1
      GROUP BY ju.id, ju.nombre
      ORDER BY total_victorias DESC
      LIMIT 1
      ''',
      [idJuego],
    );

    final totalPartidas = convertirEntero(
      filaTotales['total_partidas'],
    );

    final duracionMediaMinutos = convertirDecimal(
      filaTotales['duracion_media'],
    );

    final jugadorMasVictorias = resultadoJugadorMasVictorias.isEmpty
        ? 'Sin datos'
        : resultadoJugadorMasVictorias.first.fields['nombre_jugador']
            .toString();

    int victoriasJugadorMasVictorias = 0;
    int partidasJugadorMasVictorias = 0;

    if (resultadoJugadorMasVictorias.isNotEmpty) {
      final filaJugador = resultadoJugadorMasVictorias.first.fields;

      victoriasJugadorMasVictorias = convertirEntero(
        filaJugador['total_victorias'],
      );

      final idJugador = convertirEntero(
        filaJugador['id_jugador'],
      );

      final resultadoPartidasJugador = await conexion.query(
        '''
        SELECT COUNT(*) AS total_partidas_jugador
        FROM participaciones pa
        INNER JOIN partidas p ON pa.id_partida = p.id
        WHERE pa.id_jugador = ?
          AND p.id_juego = ?
        ''',
        [idJugador, idJuego],
      );

      partidasJugadorMasVictorias = convertirEntero(
        resultadoPartidasJugador.first.fields['total_partidas_jugador'],
      );
    }

    return EstadisticasJuego(
      totalPartidas: totalPartidas,
      jugadorMasVictorias: jugadorMasVictorias,
      victoriasJugadorMasVictorias: victoriasJugadorMasVictorias,
      partidasJugadorMasVictorias: partidasJugadorMasVictorias,
      duracionMediaMinutos: duracionMediaMinutos,
    );
  } finally {
    await conexion.close();
  }
}

}
