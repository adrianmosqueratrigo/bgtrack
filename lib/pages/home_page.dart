import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'juegos_page.dart';
import 'mi_cuenta_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int paginaSeleccionada = 0;

  final List<String> titulos = [
    'Jugadores',
    'Juegos',
    'Nueva partida',
    'Partidas',
    'Mi cuenta',
  ];

  final List<Widget> paginas = const [
    _PaginaPendiente(titulo: 'Jugadores'),
    JuegosPage(),
    _PaginaPendiente(titulo: 'Nueva partida'),
    _PaginaPendiente(titulo: 'Partidas'),
    MiCuentaPage(),
  ];

  void cambiarPagina(int index) {
    setState(() {
      paginaSeleccionada = index;
    });
  }

  void abrirFormularioNuevoJuego() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formulario de juego pendiente de implementar'),
      ),
    );
  }

  void abrirEstadisticas() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const _EstadisticasPage(),
      ),
    );
  }

  List<Widget>? accionesAppBar() {
    if (paginaSeleccionada == 1) {
      return [
        IconButton(
          tooltip: 'Añadir juego',
          icon: const Icon(Icons.add),
          onPressed: abrirFormularioNuevoJuego,
        ),
      ];
    }

    if (paginaSeleccionada == 3) {
      return [
        IconButton(
          tooltip: 'Estadísticas',
          icon: const Icon(Icons.bar_chart),
          onPressed: abrirEstadisticas,
        ),
      ];
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulos[paginaSeleccionada]),
        actions: accionesAppBar(),
      ),
      body: paginas[paginaSeleccionada],
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppTheme.secondaryTextColor,
                width: 0.6,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: paginaSeleccionada,
            onDestinationSelected: cambiarPagina,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.groups),
                label: 'Jugadores',
              ),
              NavigationDestination(
                icon: Icon(Icons.extension),
                label: 'Juegos',
              ),
              NavigationDestination(
                icon: Icon(Icons.add_circle_outline),
                label: 'Nueva',
              ),
              NavigationDestination(
                icon: Icon(Icons.history),
                label: 'Partidas',
              ),
              NavigationDestination(
                icon: Icon(Icons.person),
                label: 'Cuenta',
              ),
            ],
          ),
        ),
    );
  }
}

class _PaginaPendiente extends StatelessWidget {
  final String titulo;

  const _PaginaPendiente({
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        titulo,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class _EstadisticasPage extends StatelessWidget {
  const _EstadisticasPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      body: Center(
        child: Text(
          'Estadísticas',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}