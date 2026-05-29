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
        futureEstadisticasJugador = EstadisticasService()
            .obtenerEstadisticasJugador(jugador.id!);
      }
    });
  }

  void cambiarJuegoSeleccionado(Juego? juego) {
    setState(() {
      juegoSeleccionado = juego;

      if (juego == null) {
        futureEstadisticasJuego = null;
      } else {
        futureEstadisticasJuego = EstadisticasService()
            .obtenerEstadisticasJuego(juego.id!);
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Icon(
            desplegado ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          ),
        ],
      ),
    );
  }

  TableRow construirFilaTablaEstadistica(String titulo, String valor) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12, bottom: 10),
          child: Text(
            titulo,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            valor,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget construirCardEstadisticas(EstadisticasGenerales estadisticas) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            construirCabeceraDesplegable(
              titulo: 'ESTADÍSTICAS GENERALES',
              desplegado: estadisticasGeneralesDesplegadas,
              onTap: () {
                setState(() {
                  estadisticasGeneralesDesplegadas =
                      !estadisticasGeneralesDesplegadas;
                });
              },
            ),
            if (estadisticasGeneralesDesplegadas) ...[
              const SizedBox(height: 10),
              Table(
                columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.top,
                children: [
                  construirFilaTablaEstadistica(
                    'Partidas totales',
                    estadisticas.totalPartidas.toString(),
                  ),
                  construirFilaTablaEstadistica(
                    'Partidas cancel.',
                    estadisticas.partidasCanceladas.toString(),
                  ),
                  construirFilaTablaEstadistica(
                    'Juego más jugado',
                    estadisticas.juegoMasJugado,
                  ),
                  construirFilaTablaEstadistica(
                    'Jug. más victorias',
                    '${estadisticas.jugadorMasVictorias} '
                        '(${estadisticas.victoriasJugadorMasVictorias} de '
                        '${estadisticas.partidasJugadorMasVictorias})',
                  ),
                  construirFilaTablaEstadistica(
                    'Mejor ratio vict.',
                    '${estadisticas.jugadorMejorRatio} '
                        '(${formatearPorcentaje(estadisticas.mejorRatioVictorias)})',
                  ),
                  construirFilaTablaEstadistica(
                    'Avg. part. jugador',
                    formatearDecimal(estadisticas.partidasMediasPorJugador),
                  ),
                  construirFilaTablaEstadistica(
                    'Avg. duración',
                    '${formatearDecimal(estadisticas.duracionMediaMinutos)} min',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget construirCardSelectorJugador(List<Jugador> jugadores) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            construirCabeceraDesplegable(
              titulo: 'ESTADÍSTICAS POR JUGADOR',
              desplegado: estadisticasJugadorDesplegadas,
              onTap: () {
                setState(() {
                  estadisticasJugadorDesplegadas =
                      !estadisticasJugadorDesplegadas;
                });
              },
            ),
            if (estadisticasJugadorDesplegadas) ...[
              const SizedBox(height: 20),
              DropdownButtonFormField<Jugador>(
                initialValue: jugadorSeleccionado,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Jugador',
                  prefixIcon: Icon(Icons.person),
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
              ),
              if (futureEstadisticasJugador != null) ...[
                const SizedBox(height: 20),
                FutureBuilder<EstadisticasJugador>(
                  future: futureEstadisticasJugador,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
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

                    return construirTablaEstadisticasJugador(
                      estadisticasJugador,
                    );
                  },
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget construirCardSelectorJuego(List<Juego> juegos) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            construirCabeceraDesplegable(
              titulo: 'ESTADÍSTICAS POR JUEGO',
              desplegado: estadisticasJuegoDesplegadas,
              onTap: () {
                setState(() {
                  estadisticasJuegoDesplegadas = !estadisticasJuegoDesplegadas;
                });
              },
            ),
            if (estadisticasJuegoDesplegadas) ...[
              const SizedBox(height: 20),
              DropdownButtonFormField<Juego>(
                initialValue: juegoSeleccionado,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Juego',
                  prefixIcon: Icon(Icons.extension),
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
              ),
              if (futureEstadisticasJuego != null) ...[
                const SizedBox(height: 20),
                FutureBuilder<EstadisticasJuego>(
                  future: futureEstadisticasJuego,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
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
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget construirTablaEstadisticasJugador(
    EstadisticasJugador estadisticasJugador,
  ) {
    return Table(
      columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: [
        construirFilaTablaEstadistica(
          'Partidas totales',
          estadisticasJugador.totalPartidas.toString(),
        ),
        construirFilaTablaEstadistica(
          'Partidas cancel.',
          estadisticasJugador.partidasCanceladas.toString(),
        ),
        construirFilaTablaEstadistica(
          'Juego más jugado',
          estadisticasJugador.juegoMasJugado,
        ),
        construirFilaTablaEstadistica(
          'Victorias totales',
          estadisticasJugador.totalVictorias.toString(),
        ),
        construirFilaTablaEstadistica(
          'Ratio victorias',
          formatearPorcentaje(estadisticasJugador.ratioVictorias),
        ),
        construirFilaTablaEstadistica(
          'Avg. duración',
          '${formatearDecimal(estadisticasJugador.duracionMediaMinutos)} min',
        ),
      ],
    );
  }

  Widget construirTablaEstadisticasJuego(EstadisticasJuego estadisticasJuego) {
    return Table(
      columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: [
        construirFilaTablaEstadistica(
          'Partidas totales',
          estadisticasJuego.totalPartidas.toString(),
        ),
        construirFilaTablaEstadistica(
          'Jug. más victorias',
          estadisticasJuego.jugadorMasVictorias == 'Sin datos'
              ? 'Sin datos'
              : '${estadisticasJuego.jugadorMasVictorias} '
                    '(${estadisticasJuego.victoriasJugadorMasVictorias} de '
                    '${estadisticasJuego.partidasJugadorMasVictorias})',
        ),
        construirFilaTablaEstadistica(
          'Avg. duración',
          '${formatearDecimal(estadisticasJuego.duracionMediaMinutos)} min',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: AppBackground(
        child: FutureBuilder<EstadisticasGenerales>(
          future: futureEstadisticas,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error al cargar estadísticas:\n${snapshot.error}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }

            final estadisticas = snapshot.data;

            if (estadisticas == null) {
              return const Center(
                child: Text('No hay estadísticas disponibles.'),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  construirCardEstadisticas(estadisticas),

                  const SizedBox(height: 10),

                  FutureBuilder<List<Jugador>>(
                    future: futureJugadores,
                    builder: (context, jugadoresSnapshot) {
                      if (jugadoresSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );
                      }

                      if (jugadoresSnapshot.hasError) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'Error al cargar jugadores:\n${jugadoresSnapshot.error}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        );
                      }

                      final jugadores = jugadoresSnapshot.data ?? [];

                      if (jugadores.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'No hay jugadores con partidas registradas.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      return construirCardSelectorJugador(jugadores);
                    },
                  ),

                  const SizedBox(height: 10),

                  FutureBuilder<List<Juego>>(
                    future: futureJuegos,
                    builder: (context, juegosSnapshot) {
                      if (juegosSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );
                      }

                      if (juegosSnapshot.hasError) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'Error al cargar juegos:\n${juegosSnapshot.error}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        );
                      }

                      final juegos = juegosSnapshot.data ?? [];

                      if (juegos.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'No hay juegos con partidas registradas.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      return construirCardSelectorJuego(juegos);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
