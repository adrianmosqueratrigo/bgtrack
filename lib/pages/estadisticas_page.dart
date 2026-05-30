import 'package:flutter/material.dart';

import '../models/estadisticas_generales.dart';
import '../models/estadisticas_juego.dart';
import '../models/estadisticas_jugador.dart';
import '../models/juego.dart';
import '../models/jugador.dart';
import '../services/estadisticas_service.dart';
import '../widgets/app_background.dart';

class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  
  late Future<EstadisticasGenerales> futureEstadisticas;
  late Future<List<Jugador>> futureJugadores;
  late Future<List<Juego>> futureJuegos;

  Jugador? jugadorSeleccionado;
  Juego? juegoSeleccionado;

  Future<EstadisticasJugador>? futureEstadisticasJugador;
  Future<EstadisticasJuego>? futureEstadisticasJuego;

  bool estadisticasGeneralesDesplegadas = true;
  bool estadisticasJugadorDesplegadas = true;
  bool estadisticasJuegoDesplegadas = true;

  @override
  void initState() {
    super.initState();
    futureEstadisticas = EstadisticasService().obtenerEstadisticasGenerales();
    futureJugadores = EstadisticasService().obtenerJugadoresConPartidas();
    futureJuegos = EstadisticasService().obtenerJuegosConPartidas();
  }

  String formatearDecimal(double valor) {
    return valor.toStringAsFixed(1);
  }

  String formatearPorcentaje(double valor) {
    return '${(valor * 100).toStringAsFixed(1)} %';
  }

  void cambiarJugadorSeleccionado(Jugador? jugador) {
    setState(() {
      jugadorSeleccionado = jugador;

      if (jugador == null) {
        futureEstadisticasJugador = null;
      } else {
        futureEstadisticasJugador =
            EstadisticasService().obtenerEstadisticasJugador(jugador.id!);
      }
    });
  }

  void cambiarJuegoSeleccionado(Juego? juego) {
    setState(() {
      juegoSeleccionado = juego;

      if (juego == null) {
        futureEstadisticasJuego = null;
      } else {
        futureEstadisticasJuego =
            EstadisticasService().obtenerEstadisticasJuego(juego.id!);
      }
    });
  }

  Widget construirCabeceraDesplegable({
    required String titulo,
    required bool desplegado,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Icon(
            desplegado ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
          ),
        ],
      ),
    );
  }

  Widget construirCardEstadisticas({
    required String titulo,
    required bool desplegada,
    required VoidCallback onTap,
    required Widget contenido,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            construirCabeceraDesplegable(
              titulo: titulo,
              desplegado: desplegada,
              onTap: onTap,
            ),
            if (desplegada) ...[
              const SizedBox(height: 20),
              contenido,
            ],
          ],
        ),
      ),
    );
  }

  Widget construirTabla({
    required List<TableRow> filas,
  }) {
    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: filas,
    );
  }

  TableRow construirFilaTablaEstadisticas(String titulo, String valor) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            right: 20,
            bottom: 5,
          ),
          child: Text(
            titulo,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            //bottom: 10,
          ),
          child: Text(
            valor,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget construirSeccionEstadisticasGenerales(
    EstadisticasGenerales estadisticas,
  ) {
    return construirCardEstadisticas(
      titulo: 'ESTADÍSTICAS GENERALES',
      desplegada: estadisticasGeneralesDesplegadas,
      onTap: () {
        setState(() {
          estadisticasGeneralesDesplegadas =
              !estadisticasGeneralesDesplegadas;
        });
      },
      contenido: construirTablaEstadisticasGenerales(estadisticas),
    );
  }

  Widget construirTablaEstadisticasGenerales(
    EstadisticasGenerales estadisticas,
  ) {
    return construirTabla(
      filas: [
        construirFilaTablaEstadisticas(
          'Partidas totales',
          estadisticas.totalPartidas.toString(),
        ),
        construirFilaTablaEstadisticas(
          'Partidas cancel.',
          estadisticas.partidasCanceladas.toString(),
        ),
        construirFilaTablaEstadisticas(
          'Juego más jugado',
          estadisticas.juegoMasJugado,
        ),
        construirFilaTablaEstadisticas(
          'Jug. más victorias',
          '${estadisticas.jugadorMasVictorias} '
              '(${estadisticas.victoriasJugadorMasVictorias} de '
              '${estadisticas.partidasJugadorMasVictorias})',
        ),
        construirFilaTablaEstadisticas(
          'Mejor ratio vict.',
          '${estadisticas.jugadorMejorRatio} '
              '(${formatearPorcentaje(estadisticas.mejorRatioVictorias)})',
        ),
        construirFilaTablaEstadisticas(
          'Avg. partidas',
          '${formatearDecimal(estadisticas.partidasMediasPorJugador)} part/jug',
        ),
        construirFilaTablaEstadisticas(
          'Avg. duración',
          '${formatearDecimal(estadisticas.duracionMediaMinutos)} min',
        ),
      ],
    );
  }

  Widget construirSeccionEstadisticasJugador() {
    return FutureBuilder<List<Jugador>>(
      future: futureJugadores,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return construirCardCarga();
        }

        if (snapshot.hasError) {
          return construirCardError(
            'Error al cargar jugadores:\n${snapshot.error}',
          );
        }

        final jugadores = snapshot.data ?? [];

        if (jugadores.isEmpty) {
          return construirCardMensaje(
            'No hay jugadores con partidas registradas.',
          );
        }

        return construirCardEstadisticas(
          titulo: 'ESTADÍSTICAS POR JUGADOR',
          desplegada: estadisticasJugadorDesplegadas,
          onTap: () {
            setState(() {
              estadisticasJugadorDesplegadas =
                  !estadisticasJugadorDesplegadas;
            });
          },
          contenido: construirContenidoEstadisticasJugador(jugadores),
        );
      },
    );
  }

  Widget construirContenidoEstadisticasJugador(List<Jugador> jugadores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        construirDropdownJugador(jugadores),
        if (futureEstadisticasJugador != null) ...[
          const SizedBox(height: 20),
          construirFutureEstadisticasJugador(),
        ],
      ],
    );
  }

  Widget construirDropdownJugador(List<Jugador> jugadores) {
    return DropdownButtonFormField<Jugador>(
      initialValue: jugadorSeleccionado,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Jugador',
        prefixIcon: Icon(Icons.person_2_rounded),
      ),
      items: jugadores.map((jugador) {
        return DropdownMenuItem(
          value: jugador,
          child: Text(
            jugador.nombre,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: cambiarJugadorSeleccionado,
    );
  }

  Widget construirFutureEstadisticasJugador() {
    return FutureBuilder<EstadisticasJugador>(
      future: futureEstadisticasJugador,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Error al cargar estadísticas del jugador:\n${snapshot.error}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          );
        }

        final estadisticasJugador = snapshot.data;

        if (estadisticasJugador == null) {
          return const Text('No hay datos para este jugador.');
        }

        return construirTablaEstadisticasJugador(estadisticasJugador);
      },
    );
  }

  Widget construirTablaEstadisticasJugador(
    EstadisticasJugador estadisticasJugador,
  ) {
    return construirTabla(
      filas: [
        construirFilaTablaEstadisticas(
          'Partidas totales',
          estadisticasJugador.totalPartidas.toString(),
        ),
        construirFilaTablaEstadisticas(
          'Partidas cancel.',
          estadisticasJugador.partidasCanceladas.toString(),
        ),
        construirFilaTablaEstadisticas(
          'Juego más jugado',
          estadisticasJugador.juegoMasJugado,
        ),
        construirFilaTablaEstadisticas(
          'Victorias totales',
          estadisticasJugador.totalVictorias.toString(),
        ),
        construirFilaTablaEstadisticas(
          'Ratio victorias',
          formatearPorcentaje(estadisticasJugador.ratioVictorias),
        ),
        construirFilaTablaEstadisticas(
          'Avg. duración',
          '${formatearDecimal(estadisticasJugador.duracionMediaMinutos)} min',
        ),
      ],
    );
  }

  Widget construirSeccionEstadisticasJuego() {
    return FutureBuilder<List<Juego>>(
      future: futureJuegos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return construirCardCarga();
        }

        if (snapshot.hasError) {
          return construirCardError(
            'Error al cargar juegos:\n${snapshot.error}',
          );
        }

        final juegos = snapshot.data ?? [];

        if (juegos.isEmpty) {
          return construirCardMensaje(
            'No hay juegos con partidas registradas.',
          );
        }

        return construirCardEstadisticas(
          titulo: 'ESTADÍSTICAS POR JUEGO',
          desplegada: estadisticasJuegoDesplegadas,
          onTap: () {
            setState(() {
              estadisticasJuegoDesplegadas = !estadisticasJuegoDesplegadas;
            });
          },
          contenido: construirContenidoEstadisticasJuego(juegos),
        );
      },
    );
  }

  Widget construirContenidoEstadisticasJuego(List<Juego> juegos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        construirDropdownJuego(juegos),
        if (futureEstadisticasJuego != null) ...[
          const SizedBox(height: 20),
          construirFutureEstadisticasJuego(),
        ],
      ],
    );
  }

  Widget construirDropdownJuego(List<Juego> juegos) {
    return DropdownButtonFormField<Juego>(
      initialValue: juegoSeleccionado,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Juego',
        prefixIcon: Icon(Icons.casino_rounded),
      ),
      items: juegos.map((juego) {
        return DropdownMenuItem(
          value: juego,
          child: Text(
            juego.nombre,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: cambiarJuegoSeleccionado,
    );
  }

  Widget construirFutureEstadisticasJuego() {
    return FutureBuilder<EstadisticasJuego>(
      future: futureEstadisticasJuego,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Error al cargar estadísticas del juego:\n${snapshot.error}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          );
        }

        final estadisticasJuego = snapshot.data;

        if (estadisticasJuego == null) {
          return const Text('No hay datos para este juego.');
        }

        return construirTablaEstadisticasJuego(estadisticasJuego);
      },
    );
  }

  Widget construirTablaEstadisticasJuego(
    EstadisticasJuego estadisticasJuego,
  ) {
    return construirTabla(
      filas: [
        construirFilaTablaEstadisticas(
          'Partidas totales',
          estadisticasJuego.totalPartidas.toString(),
        ),
        construirFilaTablaEstadisticas(
          'Jug. más victorias',
          estadisticasJuego.jugadorMasVictorias == 'Sin datos'
              ? 'Sin datos'
              : '${estadisticasJuego.jugadorMasVictorias} '
                    '(${estadisticasJuego.victoriasJugadorMasVictorias} de '
                    '${estadisticasJuego.partidasJugadorMasVictorias})',
        ),
        construirFilaTablaEstadisticas(
          'Avg. duración',
          '${formatearDecimal(estadisticasJuego.duracionMediaMinutos)} min',
        ),
      ],
    );
  }

  Widget construirCardCarga() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget construirCardError(String mensaje) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          mensaje,
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }

  Widget construirCardMensaje(String mensaje) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          mensaje,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget construirContenido(
    EstadisticasGenerales estadisticas,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        children: [
          construirSeccionEstadisticasGenerales(estadisticas),
          const SizedBox(height: 5),
          construirSeccionEstadisticasJugador(),
          const SizedBox(height: 5),
          construirSeccionEstadisticasJuego(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget construirBody() {
    return AppBackground(
      child: FutureBuilder<EstadisticasGenerales>(
        future: futureEstadisticas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Error al cargar estadísticas:\n${snapshot.error}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          }

          final estadisticas = snapshot.data;

          if (estadisticas == null) {
            return const Center(
              child: Text('No hay estadísticas disponibles.'),
            );
          }

          return construirContenido(estadisticas);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      body: construirBody(),
    );
  }
}