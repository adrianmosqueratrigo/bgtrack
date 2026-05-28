import 'package:flutter/material.dart';

import '../models/participante_partida.dart';
import '../models/partida_detalle.dart';
import '../models/partida_resumen.dart';
import '../services/partidas_service.dart';

class PartidasPage extends StatefulWidget {
  const PartidasPage({super.key});

  @override
  State<PartidasPage> createState() => _PartidasPageState();
}

class _PartidasPageState extends State<PartidasPage> {
  late Future<List<PartidaResumen>> futurePartidas;

  @override
  void initState() {
    super.initState();
    cargarPartidas();
  }

  void cargarPartidas() {
    futurePartidas = PartidasService().obtenerPartidas();
  }

  String textoFechaHora(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$anio $hora:$minuto';
  }

  String textoDuracion(int? duracion) {
    if (duracion == null) {
      return 'Duración desconocida';
    }
    return '$duracion min';
  }

  String textoGanadoresParticipantes(List<ParticipantePartida> participantes) {
    final ganadores = participantes
        .where((participante) => participante.esGanador)
        .map((participante) => participante.nombreJugador)
        .toList();

    if (ganadores.isEmpty) {
      return 'Sin ganador';
    }

    return ganadores.join(', ');
  }

  String textoEstado(String estado) {
    if (estado == 'finalizada') {
      return 'Finalizada';
    }

    if (estado == 'cancelada') {
      return 'Cancelada';
    }

    return estado;
  }

  Color colorEstado(String estado) {
    if (estado == 'finalizada') {
      return Colors.green;
    }

    if (estado == 'cancelada') {
      return Colors.red;
    }

    return Colors.orange;
  }

  IconData iconoEstado(String estado) {
    if (estado == 'finalizada') {
      return Icons.check_circle;
    }

    if (estado == 'cancelada') {
      return Icons.cancel;
    }

    return Icons.info;
  }

  Future<void> mostrarDetallePartida(PartidaResumen partida) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final detalle = await PartidasService().obtenerDetallePartida(partida.id);
      final participantes =
          await PartidasService().obtenerParticipantesPartida(partida.id);

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      if (detalle == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontró el detalle de la partida'),
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) {
          return construirDialogDetalle(detalle, participantes);
        },
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar el detalle: $e'),
        ),
      );
    }
  }

  Widget construirDialogDetalle(
    PartidaDetalle detalle,
    List<ParticipantePartida> participantes,
  ) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 50,
      ),
      title: Center(
        child: Text(
          'Partida nº ${detalle.id}',
          textAlign: TextAlign.center,
          ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              construirLineaDetalle('Juego', detalle.nombreJuego),
              construirLineaDetalle('Fecha', textoFechaHora(detalle.fechaHora)),
              construirLineaDetalle('Estado', textoEstado(detalle.estado)),
              construirLineaDetalle('Duración', textoDuracion(detalle.duracionMinutos)),
              construirLineaDetalle('Ganador', textoGanadoresParticipantes(participantes),),
              
              const SizedBox(height: 15),

              Text(
                'Participantes',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),

              if (participantes.isEmpty)
                Text(
                  'No hay participantes registrados.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                Column(
                  children: participantes.map((participante) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              participante.nombreJugador,
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Text(
                            participante.puntuacion == null
                                ? 'Sin puntuación'
                                : '${participante.puntuacion} pts',
                            textAlign: TextAlign.right,
                          ),
                          if (participante.esGanador) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.emoji_events,
                              size: 18,
                              color: Colors.amber,
                            ),
                          ] else
                            const SizedBox(width: 24),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 12),
              Text(
                'Observaciones',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                detalle.notas == null || detalle.notas!.trim().isEmpty
                    ? 'Sin observaciones'
                    : detalle.notas!,
              ),
            ],
          ),
        ),
      ),
      
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cerrar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

Widget construirLineaDetalle(String titulo, String valor) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      children: [
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  );
}

  Widget construirCardPartida(
    BuildContext context,
    PartidaResumen partida,
    Color primaryColor,
    Color secondaryTextColor,
  ) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => mostrarDetallePartida(partida),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                child: Text(
                  partida.id.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      partida.nombreJuego,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${textoFechaHora(partida.fechaHora)}',
                      style: TextStyle(
                        color: secondaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Duración: ${textoDuracion(partida.duracionMinutos)}',
                      style: TextStyle(
                        color: secondaryTextColor,
                      ),
                    ),
                    Text(
                      'Jugadores: ${partida.numeroJugadores}',
                      style: TextStyle(
                        color: secondaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Icon(
                iconoEstado(partida.estado),
                color: colorEstado(partida.estado),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color secondaryTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

    return FutureBuilder<List<PartidaResumen>>(
      future: futurePartidas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error al cargar partidas:\n${snapshot.error}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          );
        }

        final partidas = snapshot.data ?? [];

        if (partidas.isEmpty) {
          return const Center(
            child: Text('No hay partidas registradas.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: partidas.length,
          itemBuilder: (context, index) {
            final partida = partidas[index];

            return construirCardPartida(
              context,
              partida,
              primaryColor,
              secondaryTextColor,
            );
          },
        );
      },
    );
  }
}