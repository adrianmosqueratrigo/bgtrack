import 'package:flutter/material.dart';

import '../models/participante_partida.dart';
import '../models/partida_detalle.dart';
import '../models/partida_resumen.dart';
import '../services/partidas_service.dart';
import '../utils/app_snackbar.dart';
import 'partida_form_page.dart';

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

  Future<void> editarPartida(PartidaResumen partida) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PartidaFormPage(partida: partida),
      ),
    );

    if (resultado == true) {
      setState(() {
        cargarPartidas();
      });
    }
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
        AppSnackbar.mostrarError(
          context,
          'No se encontró el detalle de la partida',
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

      AppSnackbar.mostrarError(context, 'Error al cargar el detalle: $e');
    }
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
      return Icons.check_circle_outline_rounded;
    }

    if (estado == 'cancelada') {
      return Icons.cancel_outlined;
    }

    return Icons.pending_outlined;
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

  String textoFechaHora(DateTime fechaHora) {
    final dia = fechaHora.day.toString().padLeft(2, '0');
    final mes = fechaHora.month.toString().padLeft(2, '0');
    final anio = fechaHora.year.toString();
    final hora = fechaHora.hour.toString().padLeft(2, '0');
    final minuto = fechaHora.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$anio $hora:$minuto';
  }

  String textoDuracion(int? duracionMinutos) {
    if (duracionMinutos == null) {
      return 'Sin duración';
    }

    return '$duracionMinutos min';
  }

  String textoGanadores(String? ganadores) {
    if (ganadores == null || ganadores.trim().isEmpty) {
      return 'Sin ganador';
    }

    return ganadores;
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

  String textoObservaciones(String? notas) {
    if (notas == null || notas.trim().isEmpty) {
      return 'Sin observaciones';
    }

    return notas;
  }

  Widget construirAvatarPartida(PartidaResumen partida, Color primaryColor) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      child: Text(
        partida.id.toString(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget construirInformacionPartida(
    PartidaResumen partida,
    Color secondaryTextColor,
  ) {
    return Expanded(
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
            textoFechaHora(partida.fechaHora),
            style: TextStyle(color: secondaryTextColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${partida.numeroJugadores} jugs. ~ '
            '${textoDuracion(partida.duracionMinutos)}',
            style: TextStyle(color: secondaryTextColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget construirAccionesPartida(PartidaResumen partida) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          iconoEstado(partida.estado),
          color: colorEstado(partida.estado),
          size: 24,
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => editarPartida(partida),
          child: const Padding(
            padding: EdgeInsets.all(2),
            child: Icon(Icons.edit, size: 24),
          ),
        ),
      ],
    );
  }

  Widget construirCardPartida(
    PartidaResumen partida,
    Color primaryColor,
    Color secondaryTextColor,
  ) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => mostrarDetallePartida(partida),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              construirAvatarPartida(partida, primaryColor),
              const SizedBox(width: 20),
              construirInformacionPartida(partida, secondaryTextColor),
              const SizedBox(width: 20),
              construirAccionesPartida(partida),
            ],
          ),
        ),
      ),
    );
  }

  Widget construirListaPartidas(
    List<PartidaResumen> partidas,
    Color primaryColor,
    Color secondaryTextColor,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      itemCount: partidas.length,
      itemBuilder: (context, index) {
        final partida = partidas[index];

        return construirCardPartida(partida, primaryColor, secondaryTextColor);
      },
    );
  }

  Widget construirCarga() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget construirError(Object error) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Text(
        'Error al cargar partidas:\n$error',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }

  Widget construirSinPartidas() {
    return const Center(child: Text('No hay partidas registradas.'));
  }

  Widget construirContenido(
    AsyncSnapshot<List<PartidaResumen>> snapshot,
    Color primaryColor,
    Color secondaryTextColor,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return construirCarga();
    }

    if (snapshot.hasError) {
      return construirError(snapshot.error!);
    }

    final partidas = snapshot.data ?? [];

    if (partidas.isEmpty) {
      return construirSinPartidas();
    }

    return construirListaPartidas(partidas, primaryColor, secondaryTextColor);
  }

  Widget construirDialogDetalle(
    PartidaDetalle detalle,
    List<ParticipantePartida> participantes,
  ) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                construirTablaDetalle(detalle, participantes),
                const SizedBox(height: 10),
                Text(
                  'Participantes',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                construirTablaParticipantes(participantes),
              ],
            ),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton.tonal(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cerrar',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget construirTablaDetalle(
    PartidaDetalle detalle,
    List<ParticipantePartida> participantes,
  ) {
    return Table(
      columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: [
        construirFilaTablaDetalle('Juego', detalle.nombreJuego),
        construirFilaTablaDetalle('Fecha', textoFechaHora(detalle.fechaHora)),
        construirFilaTablaDetalle('Estado', textoEstado(detalle.estado)),
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
          textoObservaciones(detalle.notas),
        ),
      ],
    );
  }

  TableRow construirFilaTablaDetalle(String titulo, String valor) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20, bottom: 10),
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

  Widget construirTablaParticipantes(List<ParticipantePartida> participantes) {
    if (participantes.isEmpty) {
      return Text(
        'No hay participantes registrados.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(),
        1: IntrinsicColumnWidth(),
        2: IntrinsicColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: participantes.map((participante) {
        return construirFilaTablaParticipante(participante);
      }).toList(),
    );
  }

  TableRow construirFilaTablaParticipante(ParticipantePartida participante) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5, right: 10),
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
                ? 'Sin puntuación'
                : '${participante.puntuacion} pts',
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 6),
          child: participante.esGanador
              ? const Icon(
                  Icons.emoji_events_rounded,
                  size: 22,
                  color: Colors.amber,
                )
              : const SizedBox(width: 22),
        ),
      ],
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
        return construirContenido(snapshot, primaryColor, secondaryTextColor);
      },
    );
  }
}
