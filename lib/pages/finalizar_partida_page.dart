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

  bool hayJugadoresRepetidos() {
    final ids = jugadoresSeleccionados
        .where((jugador) => jugador != null)
        .map((jugador) => jugador!.id)
        .toList();

    return ids.toSet().length != ids.length;
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

    if (estado == 'finalizada' && !ganadores.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marca al menos un ganador'),
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

    List<Participacion> participaciones = [];

    for (int i = 0; i < jugadoresSeleccionados.length; i++) {
      final jugador = jugadoresSeleccionados[i]!;
      final puntuacionTexto = puntuacionControllers[i].text.trim();

      participaciones.add(
        Participacion(
          idPartida: 0,
          idJugador: jugador.id!,
          puntuacion: puntuacionTexto.isEmpty ? null : int.parse(puntuacionTexto),
          esGanador: ganadores[i],
        ),
      );
    }

    try {
      await PartidasService().insertarPartidaCompleta(partida, participaciones);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar partida'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: widget.juego.nombre,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Juego',
                      prefixIcon: Icon(Icons.extension),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: textoDuracion(),
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Duración',
                      prefixIcon: Icon(Icons.timer),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: estado,
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
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Participantes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(jugadoresSeleccionados.length, (index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            DropdownButtonFormField<Jugador>(
                              value: jugadoresSeleccionados[index],
                              decoration: InputDecoration(
                                labelText: 'Jugador ${index + 1}',
                                prefixIcon: const Icon(Icons.person),
                              ),
                              items: widget.todosJugadores.map((jugador) {
                                return DropdownMenuItem(
                                  value: jugador,
                                  child: Text(jugador.nombre),
                                );
                              }).toList(),
                              onChanged: (jugador) {
                                setState(() {
                                  jugadoresSeleccionados[index] = jugador;
                                });
                              },
                              validator: validarJugador,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: puntuacionControllers[index],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Puntuación',
                                prefixIcon: Icon(Icons.numbers),
                                hintText: 'Opcional',
                              ),
                              validator: validarPuntuacionOpcional,
                            ),
                            const SizedBox(height: 6),
                            SwitchListTile(
                              title: const Text('Ganador'),
                              value: ganadores[index],
                              onChanged: (value) {
                                setState(() {
                                  ganadores[index] = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: notasController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Observaciones',
                      prefixIcon: Icon(Icons.notes),
                      hintText: 'Opcional',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: guardarPartida,
                      icon: const Icon(Icons.save),
                      label: const Text(
                        'Guardar partida',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}