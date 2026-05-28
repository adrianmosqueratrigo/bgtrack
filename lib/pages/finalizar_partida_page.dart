import 'package:flutter/material.dart';

import '../models/juego.dart';
import '../models/jugador.dart';
import '../models/participacion.dart';
import '../models/partida.dart';
import '../services/partidas_service.dart';

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

  @override
  void initState() {
    super.initState();

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

  @override
  void dispose() {
    for (var controller in puntuacionControllers) {
      controller.dispose();
    }

    notasController.dispose();

    super.dispose();
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

  Future<void> guardarPartida() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (hayJugadoresRepetidos()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puede haber jugadores repetidos'),
        ),
      );
      return;
    }

    final partida = Partida(
      idJuego: widget.juego.id!,
      idUsuario: 1,
      fechaHora: widget.fechaHora,
      duracionMinutos: duracionEnMinutos(),
      estado: estado,
      notas: notasController.text.trim().isEmpty
          ? null
          : notasController.text.trim(),
    );

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

    try {
      await PartidasService().insertarPartidaCompleta(
        partida,
        participaciones,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Partida guardada correctamente'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar la partida: $e'),
        ),
      );
    }
  }

  Widget construirTituloSeccion(String titulo) {
    return Text(
      titulo,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
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
            construirTituloSeccion('Resumen de partida'),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: 'widget.juego.nombre',
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Juego',
                prefixIcon: Icon(Icons.extension),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: textoFechaHora(widget.fechaHora),
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Fecha y hora de inicio',
                prefixIcon: Icon(Icons.calendar_month),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: textoDuracion(),
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Duración',
                prefixIcon: Icon(Icons.timer),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: estado,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Estado',
                prefixIcon: Icon(Icons.flag),
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
              onChanged: (value) {
                if (value != null) {
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
              },
            ),

            const SizedBox(height: 10),
            TextFormField(
              controller: notasController,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observaciones (opcional)',
                prefixIcon: Icon(Icons.notes),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget construirCardJugador(int index) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          children: [
            construirTituloSeccion('Jugador ${index + 1}'),
            const SizedBox(height: 10),
            DropdownButtonFormField<Jugador>(
              initialValue: jugadoresSeleccionados[index],
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Jugador',
                prefixIcon: Icon(Icons.person),
              ),
              items: jugadoresDisponiblesParaDropdown(index).map(
                (jugador) {
                  return DropdownMenuItem(
                    value: jugador,
                    child: Text(
                      jugador.nombre,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                },
              ).toList(),
              selectedItemBuilder: (context) {
                return jugadoresDisponiblesParaDropdown(index).map(
                  (jugador) {
                    return Text(
                      jugador.nombre,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    );
                  },
                ).toList();
              },
              onChanged: (jugador) {
                cambiarJugador(index, jugador);
              },
              validator: validarJugador,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: puntuacionControllers[index],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Puntuación (opcional)',
                prefixIcon: Icon(Icons.numbers),
                //hintText: 'Opcional',
              ),
              validator: validarPuntuacionOpcional,
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              title: const Text('Ganador'),
              value: ganadores[index],
              onChanged: estado == 'cancelada'
                  ? null
                  : (value) {
                      cambiarGanador(index, value);
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget construirSeccionGuardar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: guardarPartida,
            icon: const Icon(
              Icons.save,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar partida'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              construirSeccionResumenPartida(),
              const SizedBox(height: 2),
              ...List.generate(jugadoresSeleccionados.length, (index) {
                return Column(
                  children: [
                    construirCardJugador(index),
                    const SizedBox(height: 2),
                  ],
                );
              }),
              construirSeccionGuardar(),
            ],
          ),
        ),
      ),
    );
  }
}