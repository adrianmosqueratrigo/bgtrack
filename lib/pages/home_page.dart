import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import 'estadisticas_page.dart';
import 'juego_form_page.dart';
import 'juegos_page.dart';
import 'jugador_form_page.dart';
import 'jugadores_page.dart';
import 'mi_cuenta_page.dart';
import 'nueva_partida_page.dart';
import 'partidas_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int paginaSeleccionada = 2;
  int juegosKey = 0;
  int jugadoresKey = 0;

  final List<String> titulos = [
    'Jugadores',
    'Ludoteca',
    'Nueva partida',
    'Partidas',
    'Mi cuenta',
  ];

  List<Widget> obtenerPaginas() {
    return [
      JugadoresPage(key: ValueKey(jugadoresKey)),
      JuegosPage(key: ValueKey(juegosKey)),
      const NuevaPartidaPage(),
      const PartidasPage(),
      const MiCuentaPage(),
    ];
  }

  void cambiarPagina(int index) {
    setState(() {
      paginaSeleccionada = index;
    });
  }

  Future<void> abrirFormularioNuevoJugador() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const JugadorFormPage(),
      ),
    );

    if (resultado == true) {
      setState(() {
        jugadoresKey++;
      });
    }
  }

  Future<void> abrirFormularioNuevoJuego() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const JuegoFormPage(),
      ),
    );

    if (resultado == true) {
      setState(() {
        juegosKey++;
      });
    }
  }

  void abrirEstadisticas() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EstadisticasPage(),
      ),
    );
  }

  List<Widget>? accionesAppBar() {

    if (paginaSeleccionada == 0) {
      return [
        Padding(
          padding: const EdgeInsets.only(right: 30),
          child: IconButton(
            tooltip: 'Añadir jugador',
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              size: 32,
            ),
            onPressed: abrirFormularioNuevoJugador,
          ),
        ),
      ];
    }
    
    if (paginaSeleccionada == 1) {
      return [
        Padding(
          padding: const EdgeInsets.only(right: 30),
          child: IconButton(
            tooltip: 'Añadir juego',
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              size: 32,
            ),
            onPressed: abrirFormularioNuevoJuego,
          ),
        ),
      ];
    }

    if (paginaSeleccionada == 3) {
      return [
        Padding(
          padding: const EdgeInsets.only(right: 30),
          child: IconButton(
            tooltip: 'Estadísticas',
            icon: const Icon(
              Icons.insert_chart_outlined_rounded,
              size: 32,
            ),
            onPressed: abrirEstadisticas,
          ),
        ),
      ];
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final paginas = obtenerPaginas();

    return Scaffold(
      appBar: AppBar(
        title: Text(titulos[paginaSeleccionada]),
        actions: accionesAppBar(),
      ),
      body: AppBackground(
        child: paginas[paginaSeleccionada],
      ),
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
              icon: Icon(Icons.groups_2_outlined),
              label: 'Jugadores',
            ),
            NavigationDestination(
              icon: Icon(Icons.casino_outlined),
              label: 'Ludoteca',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              label: 'Jugar',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              label: 'Partidas',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_2_outlined),
              label: 'Mi cuena',
            ),
          ],
        ),
      ),
    );
  }
}
