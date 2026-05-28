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

  void editarPartida(PartidaResumen partida) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Editar partida nº ${partida.id} pendiente de implementar',
        ),
      ),
    );
  }

  Future<void> mostrarDetallePartida(PartidaResumen partida) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final detalle = await PartidasService().obtenerDetallePartida(partida.id);
      final participantes = await PartidasService().obtenerParticipantesPartida(
        partida.id,
      );

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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar el detalle: $e')));
    }
  }

  Widget construirDialogDetalle(
    PartidaDetalle detalle,
    List<ParticipantePartida> participantes,
  ) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      title: Center(
        child: Text(
          'Partida nº ${detalle.id}',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Datos generales',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Table(
                  columnWidths: const {
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.top,
                  children: [
                    construirFilaTablaDetalle('Juego', detalle.nombreJuego),
                    construirFilaTablaDetalle(
                      'Fecha',
                      textoFechaHora(detalle.fechaHora),
                    ),
                    construirFilaTablaDetalle(
                      'Estado',
                      textoEstado(detalle.estado),
                    ),
                    construirFilaTablaDetalle(
                      'Duración',
                      textoDuracion(detalle.duracionMinutos),
                    ),
                    construirFilaTablaDetalle(
                      'Ganador',
                      textoGanadoresParticipantes(participantes),
                    ),
                    construirFilaTablaDetalle(
                      'Observ.',
                      detalle.notas == null || detalle.notas!.trim().isEmpty
                          ? 'Sin observaciones'
                          : detalle.notas!,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  'Jugadores',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                if (participantes.isEmpty)
                  Text(
                    'No hay jugadores.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(),
                      1: IntrinsicColumnWidth(),
                      2: IntrinsicColumnWidth(),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: participantes.map((participante) {
                      return construirFilaTablaParticipante(participante);
                    }).toList(),
                  ),
              ],
            ),
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
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  TableRow construirFilaTablaDetalle(String titulo, String valor) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12, bottom: 10),
          child: Text(
            '$titulo',
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

  TableRow construirFilaTablaParticipante(ParticipantePartida participante) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, right: 12),
          child: Text(
            participante.nombreJugador,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            participante.puntuacion == null
                ? 'n/a'
                : '${participante.puntuacion} pts',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 6),
          child: participante.esGanador
              ? const Icon(Icons.emoji_events, size: 18, color: Colors.amber)
              : const SizedBox(width: 18),
        ),
      ],
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                      style: TextStyle(color: secondaryTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${partida.numeroJugadores} jugs. ~ ${textoDuracion(partida.duracionMinutos)}',
                      style: TextStyle(color: secondaryTextColor),
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconoEstado(partida.estado),
                    color: colorEstado(partida.estado),
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Editar partida',
                    icon: const Icon(Icons.edit, size: 24),
                    onPressed: () => editarPartida(partida),
                  ),
                ],
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
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error al cargar partidas:\n${snapshot.error}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        final partidas = snapshot.data ?? [];

        if (partidas.isEmpty) {
          return const Center(child: Text('No hay partidas.'));
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
