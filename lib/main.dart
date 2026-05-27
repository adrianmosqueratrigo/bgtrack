import 'package:flutter/material.dart';

import 'models/juego.dart';
import 'services/juegos_service.dart';

void main() {
  runApp(const BGTrackApp());
}

class BGTrackApp extends StatelessWidget {
  const BGTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BGTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const PruebaJuegosPage(),
    );
  }
}

class PruebaJuegosPage extends StatefulWidget {
  const PruebaJuegosPage({super.key});

  @override
  State<PruebaJuegosPage> createState() => _PruebaJuegosPageState();
}

class _PruebaJuegosPageState extends State<PruebaJuegosPage> {
  late Future<List<Juego>> futureJuegos;

  @override
  void initState() {
    super.initState();
    futureJuegos = JuegosService().obtenerJuegos();
  }

  void recargarJuegos() {
    setState(() {
      futureJuegos = JuegosService().obtenerJuegos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba JuegosService'),
        actions: [
          IconButton(
            onPressed: recargarJuegos,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Juego>>(
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
                style: const TextStyle(color: Colors.red),
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

              return ListTile(
                leading: CircleAvatar(child: Text(juego.id.toString())),
                title: Text(juego.nombre),
                subtitle: Text(
                  '${juego.jugadoresMin}-${juego.jugadoresMax} jugadores · '
                  '${juego.duracionEstimadaMinutos ?? 0} min · '
                  '${juego.tipo ?? 'Sin tipo'}',
                ),
                trailing: Icon(
                  juego.activo ? Icons.check_circle : Icons.cancel,
                  color: juego.activo ? Colors.green : Colors.red,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
