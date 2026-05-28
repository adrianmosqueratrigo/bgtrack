import 'dart:async';

import 'package:flutter/material.dart';

import '../models/juego.dart';
import '../models/jugador.dart';
import '../services/juegos_service.dart';
import '../services/jugadores_service.dart';
import '../utils/app_snackbar.dart';
import 'finalizar_partida_page.dart';

class NuevaPartidaPage extends StatefulWidget {
  const NuevaPartidaPage({super.key});

  @override
  State<NuevaPartidaPage> createState() => _NuevaPartidaPageState();
}

class _NuevaPartidaPageState extends State<NuevaPartidaPage> {
  final formKey = GlobalKey<FormState>();

  late Future<void> futureDatos;

  List<Juego> juegos = [];
  List<Jugador> jugadores = [];

  Juego? juegoSeleccionado;
  int? numeroParticipantes;
  List<Jugador?> jugadoresSeleccionados = [];

  Timer? timer;
  int segundos = 0;
  bool relojActivo = false;
  bool relojIniciado = false;
  DateTime? fechaHoraInicio;

  bool datosPartidaDesplegados = true;
  int formularioKey = 0;

  @override
  void initState() {
    super.initState();
    futureDatos = cargarDatos();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> cargarDatos() async {
    final juegosObtenidos = await JuegosService().obtenerJuegosActivos();
    final jugadoresObtenidos =
        await JugadoresService().obtenerJugadoresActivos();

    juegos = juegosObtenidos;
    jugadores = jugadoresObtenidos;
  }

  void cambiarJuego(Juego? juego) {
    setState(() {
      juegoSeleccionado = juego;
      numeroParticipantes = null;
      jugadoresSeleccionados = [];
    });
  }

  void cambiarNumeroParticipantes(int? numero) {
    if (numero == null) {
      return;
    }

    setState(() {
      numeroParticipantes = numero;

      if (jugadoresSeleccionados.length > numero) {
        jugadoresSeleccionados = jugadoresSeleccionados.sublist(0, numero);
      } else {
        while (jugadoresSeleccionados.length < numero) {
          jugadoresSeleccionados.add(null);
        }
      }
    });
  }

  void cambiarJugador(int index, Jugador? jugador) {
    setState(() {
      jugadoresSeleccionados[index] = jugador;
    });
  }

  void iniciarReloj() {
    if (relojActivo) {
      return;
    }

    fechaHoraInicio ??= DateTime.now();

    setState(() {
      relojActivo = true;
      relojIniciado = true;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        segundos++;
      });
    });
  }

  void pausarReloj() {
    timer?.cancel();

    setState(() {
      relojActivo = false;
    });
  }

  void reiniciarReloj() {
    timer?.cancel();

    setState(() {
      segundos = 0;
      relojActivo = false;
      relojIniciado = false;
      fechaHoraInicio = null;
    });
  }

  String textoReloj() {
    final horas = segundos ~/ 3600;
    final minutos = (segundos % 3600) ~/ 60;
    final segundosRestantes = segundos % 60;

    final h = horas.toString().padLeft(2, '0');
    final m = minutos.toString().padLeft(2, '0');
    final s = segundosRestantes.toString().padLeft(2, '0');

    return '$h:$m:$s';
  }

  Future<void> confirmarReinicioReloj() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: const Text(
              '¿Reiniciar reloj?',
              ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
              ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Reiniciar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
              ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      reiniciarReloj();
    }
  }

  String textoBotonReloj() {
    if (relojActivo) {
      return 'Pausar';
    }

    if (relojIniciado) {
      return 'Reanudar';
    }

    return 'Iniciar';
  }

  String? validarJugador(Jugador? jugador) {
    if (jugador == null) {
      return 'Selecciona un jugador';
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

  Future<void> finalizarPartida() async {
    if (!formKey.currentState!.validate()) {
      setState(() {
        datosPartidaDesplegados = true;
      });
      return;
    }

    if (hayJugadoresRepetidos()) {
      setState(() {
        datosPartidaDesplegados = true;
      });

    AppSnackbar.mostrar(
      context,
      'No puede haber jugadores repetidos',
    );

      return;
    }

    pausarReloj();

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinalizarPartidaPage(
          juego: juegoSeleccionado!,
          jugadoresIniciales: jugadoresSeleccionados.cast<Jugador>(),
          todosJugadores: jugadores,
          duracion: Duration(seconds: segundos),
          fechaHora: fechaHoraInicio ?? DateTime.now(),
        ),
      ),
    );

    if (resultado == true) {
      reiniciarFormulario();
    }
  }

  void reiniciarFormulario() {
    setState(() {
      juegoSeleccionado = null;
      numeroParticipantes = null;
      jugadoresSeleccionados = [];
      segundos = 0;
      relojActivo = false;
      relojIniciado = false;
      fechaHoraInicio = null;
      datosPartidaDesplegados = true;
      formularioKey++;
    });
  }

  List<DropdownMenuItem<int>> opcionesNumeroParticipantes() {
    if (juegoSeleccionado == null) {
      return [];
    }

    return List.generate(
      juegoSeleccionado!.jugadoresMax - juegoSeleccionado!.jugadoresMin + 1,
      (index) {
        final numero = juegoSeleccionado!.jugadoresMin + index;

        return DropdownMenuItem(
          value: numero,
          child: Text('$numero jugadores'),
        );
      },
    );
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
            desplegado
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
          ),
        ],
      ),
    );
  }

  Widget construirSeccionReloj() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Column(
          children: [
            
            // RELOJ.
            Text(
              textoReloj(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 60,
                  ),
            ),
            const SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: textoBotonReloj(),
                  iconSize: 42,
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: relojActivo ? pausarReloj : iniciarReloj,
                  icon: Icon(
                    relojActivo
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  tooltip: 'Reiniciar',
                  iconSize: 42,
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: confirmarReinicioReloj,
                  icon: const Icon(
                    Icons.restart_alt_rounded,
                  ),
                ),
              ],
            ),


          ],
        ),
      ),
    );
  }

  Widget construirSeccionFinalizarPartida() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: finalizarPartida,
            icon: const Icon(
              Icons.flag,
              size: 22,
            ),
            label: const Text(
              'Finalizar partida',
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


  Widget construirSeccionDatosPartida() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          children: [
            construirCabeceraDesplegable(
              titulo: 'DATOS DE LA PARTIDA',
              desplegado: datosPartidaDesplegados,
              onTap: () {
                setState(() {
                  datosPartidaDesplegados = !datosPartidaDesplegados;
                });
              },
            ),
            if (datosPartidaDesplegados) ...[
              const SizedBox(height: 10),
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
                selectedItemBuilder: (context) {
                  return juegos.map((juego) {
                    return Text(
                      juego.nombre,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    );
                  }).toList();
                },
                onChanged: cambiarJuego,
                validator: (value) {
                  if (value == null) {
                    return 'Selecciona un juego';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 10),
              if (juegoSeleccionado != null)
                DropdownButtonFormField<int>(
                  initialValue: numeroParticipantes,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Número de jugadores',
                    prefixIcon: Icon(Icons.groups),
                  ),
                  items: opcionesNumeroParticipantes(),
                  onChanged: cambiarNumeroParticipantes,
                  validator: (value) {
                    if (value == null) {
                      return 'Selecciona el número de jugadores';
                    }

                    return null;
                  },
                ),
              if (numeroParticipantes != null) ...[
                const SizedBox(height: 10),
                ...List.generate(numeroParticipantes!, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField<Jugador>(
                      initialValue: jugadoresSeleccionados[index],
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Jugador ${index + 1}',
                        prefixIcon: const Icon(Icons.person),
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
                      selectedItemBuilder: (context) {
                        return jugadores.map((jugador) {
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
                    ),
                  );
                }),
              ],
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: futureDatos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              'Error al cargar datos:\n${snapshot.error}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: KeyedSubtree(
            key: ValueKey(formularioKey),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  construirSeccionReloj(),
                  const SizedBox(height: 12),
                  construirSeccionFinalizarPartida(),
                  const SizedBox(height: 12),
                  construirSeccionDatosPartida(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}