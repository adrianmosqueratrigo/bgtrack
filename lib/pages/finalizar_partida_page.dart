import 'package:bgtrack/widgets/app_background.dart';
import 'package:flutter/material.dart';

import '../models/juego.dart';
import '../models/jugador.dart';
import '../models/participacion.dart';
import '../models/partida.dart';
import '../services/auth_service.dart';
import '../services/partidas_service.dart';
import '../utils/app_snackbar.dart';

class FinalizarPartidaPage extends StatefulWidget {
  final Juego juego;
  final List<Jugador> jugadoresIniciales;
  final List<Jugador> todosJugadores;
  final Duration duracion;
  final DateTime fechaHora;

  const FinalizarPartidaPage({
    super.key,
    required this.juego,
    required this.jugadoresIniciales,
    required this.todosJugadores,
    required this.duracion,
    required this.fechaHora,
  });

  @override
  State<FinalizarPartidaPage> createState() => _FinalizarPartidaPageState();
}

class _FinalizarPartidaPageState extends State<FinalizarPartidaPage> {
  final formKey = GlobalKey<FormState>();

  late List<Jugador?> jugadoresSeleccionados;
  late List<TextEditingController> puntuacionControllers;
  late List<bool> ganadores;

  final notasController = TextEditingController();

  String estado = 'finalizada';
  bool resumenPartidaDesplegado = true;
  bool participantesDesplegados = true;

  @override
  void initState() {
    super.initState();
    cargarDatosPartida();
  }

  @override
  void dispose() {
    for (var controller in puntuacionControllers) {
      controller.dispose();
    }

    notasController.dispose();

    super.dispose();
  }

  void cargarDatosPartida() {
    jugadoresSeleccionados = List<Jugador?>.from(widget.jugadoresIniciales);

    puntuacionControllers = List.generate(
      jugadoresSeleccionados.length,
      (_) => TextEditingController(),
    );

    ganadores = List.generate(
      jugadoresSeleccionados.length,
      (_) => false,
    );
  }

  String textoDuracion() {
    final horas = widget.duracion.inHours;
    final minutos = widget.duracion.inMinutes % 60;
    final segundos = widget.duracion.inSeconds % 60;

    final h = horas.toString().padLeft(2, '0');
    final m = minutos.toString().padLeft(2, '0');
    final s = segundos.toString().padLeft(2, '0');

    return '$h:$m:$s';
  }

  int? duracionEnMinutos() {
    if (widget.duracion.inSeconds == 0) {
      return null;
    }

    return (widget.duracion.inSeconds / 60).ceil();
  }

  String textoFechaHora(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$anio $hora:$minuto';
  }

  String? validarJugador(Jugador? jugador) {
    if (jugador == null) {
      return 'Selecciona un jugador';
    }

    return null;
  }

  String? validarPuntuacionOpcional(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final numero = int.tryParse(value);

    if (numero == null || numero < 0) {
      return 'Introduce una puntuación válida';
    }

    return null;
  }

  bool hayJugadoresRepetidos() {
    final ids = jugadoresSeleccionados
        .where((jugador) => jugador != null)
        .map((jugador) => jugador!.id)
        .toList();

    return ids.toSet().length != ids.length;
  }

  bool validarDatosPartida() {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (hayJugadoresRepetidos()) {
      AppSnackbar.mostrar(
        context,
        'No puede haber jugadores repetidos',
      );

      return false;
    }

    return true;
  }

  List<Jugador> jugadoresDisponiblesParaDropdown(int indexActual) {
    final idsSeleccionados = jugadoresSeleccionados
        .asMap()
        .entries
        .where((entry) => entry.key != indexActual)
        .where((entry) => entry.value != null)
        .map((entry) => entry.value!.id)
        .toList();

    return widget.todosJugadores.where((jugador) {
      return !idsSeleccionados.contains(jugador.id);
    }).toList();
  }

  void cambiarJugador(int index, Jugador? jugador) {
    setState(() {
      jugadoresSeleccionados[index] = jugador;
    });
  }

  void cambiarGanador(int index, bool value) {
    setState(() {
      ganadores[index] = value;
    });
  }

  void cambiarEstado(String? value) {
    if (value == null) {
      return;
    }

    setState(() {
      estado = value;

      if (estado == 'cancelada') {
        ganadores = List.generate(
          ganadores.length,
          (_) => false,
        );
      }
    });
  }

  Future<Partida?> construirPartidaDesdeFormulario() async {
    
    final idUsuario = await AuthService().obtenerIdUsuarioActual();

    if (idUsuario == null) {
      AppSnackbar.mostrarError(
        context,
        'No hay usuario iniciado',
      );

      return null;
    }

    return Partida(
      idJuego: widget.juego.id!,
      idUsuario: idUsuario,
      fechaHora: widget.fechaHora,
      duracionMinutos: duracionEnMinutos(),
      estado: estado,
      notas: notasController.text.trim().isEmpty
          ? null
          : notasController.text.trim(),
    );

  }

  List<Participacion> construirParticipacionesDesdeFormulario() {
    final List<Participacion> participaciones = [];

    for (int i = 0; i < jugadoresSeleccionados.length; i++) {
      final jugador = jugadoresSeleccionados[i]!;
      final puntuacionTexto = puntuacionControllers[i].text.trim();

      participaciones.add(
        Participacion(
          idPartida: 0,
          idJugador: jugador.id!,
          puntuacion: puntuacionTexto.isEmpty
              ? null
              : int.parse(puntuacionTexto),
          esGanador: ganadores[i],
        ),
      );
    }

    return participaciones;
  }

  Future<void> guardarPartida() async {
    if (!validarDatosPartida()) {
      return;
    }

    final partida = await construirPartidaDesdeFormulario();

    if (partida == null) {
      return;
    }

    final participaciones = construirParticipacionesDesdeFormulario();

    try {
      await PartidasService().insertarPartidaCompleta(
        partida,
        participaciones,
      );

      if (!mounted) {
        return;
      }

      AppSnackbar.mostrar(
        context,
        'Partida guardada correctamente',
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      AppSnackbar.mostrarError(
        context,
        'Error al guardar la partida',
      );
    }
    
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

  Widget construirSeccionResumenPartida() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          children: [
            construirCabeceraDesplegable(
              titulo: 'Resumen',
              desplegado: resumenPartidaDesplegado,
              onTap: () {
                setState(() {
                  resumenPartidaDesplegado = !resumenPartidaDesplegado;
                });
              },
            ),
            if (resumenPartidaDesplegado) ...[
              const SizedBox(height: 10),
              construirCampoJuego(),
              const SizedBox(height: 10),
              construirCampoFechaHora(),
              const SizedBox(height: 10),
              construirCampoDuracion(),
              const SizedBox(height: 10),
              construirCampoEstado(),
              const SizedBox(height: 10),
              construirCampoObservaciones(),
            ],
          ],
        ),
      ),
    );
  }

  Widget construirCampoJuego() {
    return TextFormField(
      initialValue: widget.juego.nombre,
      enabled: false,
      decoration: const InputDecoration(
        labelText: 'Juego',
        prefixIcon: Icon(Icons.casino_rounded),
      ),
    );
  }

  Widget construirCampoFechaHora() {
    return TextFormField(
      initialValue: textoFechaHora(widget.fechaHora),
      enabled: false,
      decoration: const InputDecoration(
        labelText: 'Fecha y hora de inicio',
        prefixIcon: Icon(Icons.calendar_month_rounded),
      ),
    );
  }

  Widget construirCampoDuracion() {
    return TextFormField(
      initialValue: textoDuracion(),
      enabled: false,
      decoration: const InputDecoration(
        labelText: 'Duración',
        prefixIcon: Icon(Icons.timer_rounded),
      ),
    );
  }

  Widget construirCampoEstado() {
    return DropdownButtonFormField<String>(
      initialValue: estado,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Estado',
        prefixIcon: Icon(Icons.flag_rounded),
      ),
      items: const [
        DropdownMenuItem(
          value: 'finalizada',
          child: Text('Finalizada'),
        ),
        DropdownMenuItem(
          value: 'cancelada',
          child: Text('Cancelada'),
        ),
      ],
      onChanged: cambiarEstado,
    );
  }

  Widget construirCampoObservaciones() {
    return TextFormField(
      controller: notasController,
      minLines: 1,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Observaciones (opcional)',
        prefixIcon: Icon(Icons.notes_sharp),
      ),
    );
  }

  Widget construirSeccionJugadores() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          children: [
            construirCabeceraDesplegable(
              titulo: 'Participantes',
              desplegado: participantesDesplegados,
              onTap: () {
                setState(() {
                  participantesDesplegados = !participantesDesplegados;
                });
              },
            ),
            if (participantesDesplegados) ...[
              const SizedBox(height: 10),
              ...List.generate(jugadoresSeleccionados.length, (index) {
                return construirBloqueJugador(index);
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget construirBloqueJugador(int index) {
    return Column(
      children: [
        construirFormularioJugador(index),
        if (index < jugadoresSeleccionados.length - 1) ...[
          const Divider(),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget construirFormularioJugador(int index) {
    return Column(
      children: [
        const SizedBox(height: 10),
        construirDropdownJugador(index),
        const SizedBox(height: 10),
        construirCampoPuntuacion(index),
        construirSwitchGanador(index),
      ],
    );
  }

  Widget construirDropdownJugador(int index) {
    return DropdownButtonFormField<Jugador>(
      initialValue: jugadoresSeleccionados[index],
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Jugador ${index + 1}',
        prefixIcon: const Icon(Icons.person_2_rounded),
      ),
      items: jugadoresDisponiblesParaDropdown(index).map((jugador) {
        return DropdownMenuItem(
          value: jugador,
          child: Text(
            jugador.nombre,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      selectedItemBuilder: (context) {
        return jugadoresDisponiblesParaDropdown(index).map((jugador) {
          return Text(
            jugador.nombre,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          );
        }).toList();
      },
      onChanged: (jugador) {
        cambiarJugador(index, jugador);
      },
      validator: validarJugador,
    );
  }

  Widget construirCampoPuntuacion(int index) {
    return TextFormField(
      controller: puntuacionControllers[index],
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Puntuación (opcional)',
        prefixIcon: Icon(Icons.numbers_rounded),
      ),
      validator: validarPuntuacionOpcional,
    );
  }

  Widget construirSwitchGanador(int index) {
    return SwitchListTile(
      title: const Text('Ganador'),
      value: ganadores[index],
      onChanged: estado == 'cancelada'
          ? null
          : (value) {
              cambiarGanador(index, value);
            },
    );
  }

  Widget construirSeccionGuardar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: guardarPartida,
          icon: const Icon(
            Icons.save_rounded,
            size: 22,
          ),
          label: const Text(
            'Guardar partida',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget construirContenidoFormulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            construirSeccionResumenPartida(),
            construirSeccionJugadores(),
            construirSeccionGuardar(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget construirContenido() {
    return AppBackground(
      child: construirContenidoFormulario(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar partida'),
      ),
      body: construirContenido(),
    );
  }
}