import 'package:flutter/material.dart';

import '../models/jugador.dart';
import '../services/jugadores_service.dart';

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

  Color colorEstado(bool activo) {
    return activo ? Colors.green : Colors.red;
  }

  IconData iconoEstado(bool activo) {
    return activo ? Icons.check_circle : Icons.cancel;
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

  void editarJugador(Jugador jugador) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editar ${jugador.nombre} pendiente de implementar'),
      ),
    );
  }

  Widget construirCardJugador(
    BuildContext context,
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
            CircleAvatar(
              radius: 20,
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(
                Icons.person,
                size: 22,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
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
                    '${textoEdad(jugador.fechaNacimiento)} · ${jugador.residencia ?? 'Residencia desconocida'}',
                    style: TextStyle(
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Column(
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
            ),
          ],
        ),
      ),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error al cargar jugadores:\n${snapshot.error}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          );
        }

        final jugadores = snapshot.data ?? [];

        if (jugadores.isEmpty) {
          return const Center(
            child: Text('No hay jugadores registrados.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: jugadores.length,
          itemBuilder: (context, index) {
            final jugador = jugadores[index];

            return construirCardJugador(
              context,
              jugador,
              primaryColor,
              secondaryTextColor,
            );
          },
        );
      },
    );
  }
}