import 'package:flutter/material.dart';

import '../models/jugador.dart';
import '../services/jugadores_service.dart';
import 'jugador_form_page.dart';

class JugadoresPage extends StatefulWidget {
  const JugadoresPage({super.key});

  @override
  State<JugadoresPage> createState() => _JugadoresPageState();
}

class _JugadoresPageState extends State<JugadoresPage> {
  late Future<List<Jugador>> futureJugadores;

  @override
  void initState() {
    super.initState();
    cargarJugadores();
  }

  void cargarJugadores() {
    futureJugadores = JugadoresService().obtenerJugadores();
  }

  Future<void> editarJugador(Jugador jugador) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JugadorFormPage(jugador: jugador),
      ),
    );

    if (resultado == true) {
      setState(() {
        cargarJugadores();
      });
    }
  }

  Color colorEstado(bool activo) {
    return activo ? Colors.green : Colors.red;
  }

  IconData iconoEstado(bool activo) {
    return activo ? Icons.check_circle_outline_rounded : Icons.cancel_outlined;
  }

  String textoEdad(DateTime? fechaNacimiento) {
    if (fechaNacimiento == null) {
      return 'Edad desconocida';
    }

    final hoy = DateTime.now();

    int edad = hoy.year - fechaNacimiento.year;

    final yaCumplioEsteAnio =
        hoy.month > fechaNacimiento.month ||
        (hoy.month == fechaNacimiento.month && hoy.day >= fechaNacimiento.day);

    if (!yaCumplioEsteAnio) {
      edad--;
    }

    return '$edad años';
  }

  String textoResidencia(String? residencia) {
    if (residencia == null || residencia.trim().isEmpty) {
      return 'Residencia desconocida';
    }

    return residencia;
  }

  Widget construirAvatarJugador(Color primaryColor) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      child: const Icon(
        Icons.person_2_rounded,
        size: 28,
      ),
    );
  }

  Widget construirInformacionJugador(
    Jugador jugador,
    Color secondaryTextColor,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            jugador.nombre,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            '${textoEdad(jugador.fechaNacimiento)} · '
            '${textoResidencia(jugador.residencia)}',
            style: TextStyle(
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget construirAccionesJugador(Jugador jugador) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          iconoEstado(jugador.activo),
          color: colorEstado(jugador.activo),
          size: 24,
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => editarJugador(jugador),
          child: const Padding(
            padding: EdgeInsets.all(2),
            child: Icon(
              Icons.edit,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget construirCardJugador(
    Jugador jugador,
    Color primaryColor,
    Color secondaryTextColor,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            construirAvatarJugador(primaryColor),
            const SizedBox(width: 20),
            construirInformacionJugador(
              jugador,
              secondaryTextColor,
            ),
            const SizedBox(width: 20),
            construirAccionesJugador(jugador),
          ],
        ),
      ),
    );
  }

  Widget construirListaJugadores(
    List<Jugador> jugadores,
    Color primaryColor,
    Color secondaryTextColor,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      itemCount: jugadores.length,
      itemBuilder: (context, index) {
        final jugador = jugadores[index];

        return construirCardJugador(
          jugador,
          primaryColor,
          secondaryTextColor,
        );
      },
    );
  }

  Widget construirCarga() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget construirError(Object error) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        'Error al cargar jugadores:\n$error',
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }

  Widget construirSinJugadores() {
    return const Center(
      child: Text('No hay jugadores registrados.'),
    );
  }

  Widget construirContenido(
    AsyncSnapshot<List<Jugador>> snapshot,
    Color primaryColor,
    Color secondaryTextColor,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return construirCarga();
    }

    if (snapshot.hasError) {
      return construirError(snapshot.error!);
    }

    final jugadores = snapshot.data ?? [];

    if (jugadores.isEmpty) {
      return construirSinJugadores();
    }

    return construirListaJugadores(
      jugadores,
      primaryColor,
      secondaryTextColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    final Color secondaryTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

    return FutureBuilder<List<Jugador>>(
      future: futureJugadores,
      builder: (context, snapshot) {
        return construirContenido(
          snapshot,
          primaryColor,
          secondaryTextColor,
        );
      },
    );
  }
}