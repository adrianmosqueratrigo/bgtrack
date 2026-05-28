import 'package:flutter/material.dart';

import '../models/juego.dart';
import '../services/juegos_service.dart';
import 'juego_form_page.dart';

class JuegosPage extends StatefulWidget {
  const JuegosPage({super.key});

  @override
  State<JuegosPage> createState() => _JuegosPageState();
}

class _JuegosPageState extends State<JuegosPage> {
  late Future<List<Juego>> futureJuegos;

  @override
  void initState() {
    super.initState();
    cargarJuegos();
  }

  void cargarJuegos() {
    futureJuegos = JuegosService().obtenerJuegos();
  }

  Color colorEstado(bool activo) {
    return activo ? Colors.green : Colors.red;
  }

  IconData iconoEstado(bool activo) {
    return activo ? Icons.check_circle : Icons.cancel;
  }

  void editarJuego(Juego juego) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JuegoFormPage(juego: juego),
      ),
    );

    if (resultado == true) {
      setState(() {
        cargarJuegos();
      });
    }
    
  }

  // CONSTRUIR LOS CARDS DE JUEGOS.
  Widget construirCardJuego(
    BuildContext context,
    Juego juego,
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
              radius: 22,
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(
                Icons.extension,
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
                    juego.nombre,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    juego.tipo ?? 'Sin tipo',
                    style: TextStyle(
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${juego.jugadoresMin}-${juego.jugadoresMax} jugs. ~ '
                    '${juego.duracionEstimadaMinutos ?? 0} min',
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
                  iconoEstado(juego.activo),
                  color: colorEstado(juego.activo),
                  size: 24,
                ),
                const SizedBox(height: 6),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => editarJuego(juego),
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

    return FutureBuilder<List<Juego>>(
      future: futureJuegos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error al cargar juegos:\n${snapshot.error}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        final juegos = snapshot.data ?? [];

        if (juegos.isEmpty) {
          return const Center(child: Text('No hay juegos registrados.'));
        }

        return ListView.builder(
          itemCount: juegos.length,
          itemBuilder: (context, index) {
            final juego = juegos[index];

            return construirCardJuego(
              context,
              juego,
              primaryColor,
              secondaryTextColor,
            );
          },
        );
      },
    );
  }
}
