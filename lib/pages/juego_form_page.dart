import 'package:flutter/material.dart';

import '../models/juego.dart';
import '../services/juegos_service.dart';
import '../utils/app_snackbar.dart';
import '../widgets/app_background.dart';

class JuegoFormPage extends StatefulWidget {
  final Juego? juego;

  const JuegoFormPage({
    super.key,
    this.juego,
  });

  @override
  State<JuegoFormPage> createState() => _JuegoFormPageState();
}

class _JuegoFormPageState extends State<JuegoFormPage> {
  final formKey = GlobalKey<FormState>();

  final nombreController = TextEditingController();
  final tipoController = TextEditingController();
  final duracionController = TextEditingController();
  final jugadoresMinController = TextEditingController();
  final jugadoresMaxController = TextEditingController();

  bool activo = true;

  bool get esEdicion {
    return widget.juego != null;
  }

  @override
  void initState() {
    super.initState();
    cargarDatosJuego();
  }

  @override
  void dispose() {
    nombreController.dispose();
    tipoController.dispose();
    duracionController.dispose();
    jugadoresMinController.dispose();
    jugadoresMaxController.dispose();
    super.dispose();
  }

  void cargarDatosJuego() {
    if (!esEdicion) {
      return;
    }

    final juego = widget.juego!;

    nombreController.text = juego.nombre;
    tipoController.text = juego.tipo ?? '';
    duracionController.text = juego.duracionEstimadaMinutos?.toString() ?? '';
    jugadoresMinController.text = juego.jugadoresMin.toString();
    jugadoresMaxController.text = juego.jugadoresMax.toString();
    activo = juego.activo;
  }

  Juego construirJuegoDesdeFormulario() {
    return Juego(
      id: widget.juego?.id,
      nombre: nombreController.text.trim(),
      tipo: tipoController.text.trim().isEmpty
          ? null
          : tipoController.text.trim(),
      duracionEstimadaMinutos: duracionController.text.trim().isEmpty
          ? null
          : int.parse(duracionController.text.trim()),
      jugadoresMin: int.parse(jugadoresMinController.text.trim()),
      jugadoresMax: int.parse(jugadoresMaxController.text.trim()),
      activo: activo,
    );
  }

  Future<void> guardarJuego() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final juego = construirJuegoDesdeFormulario();

    try {
      if (esEdicion) {
        await JuegosService().actualizarJuego(juego);
      } else {
        await JuegosService().insertarJuego(juego);
      }

      if (!mounted) {
        return;
      }

      AppSnackbar.mostrar(
        context,
        esEdicion
            ? 'Juego actualizado correctamente'
            : 'Juego guardado correctamente',
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      AppSnackbar.mostrarError(
        context,
        'Error al guardar el juego',
      );
    }
  }

  String? validarObligatorio(String? value, String mensaje) {
    if (value == null || value.trim().isEmpty) {
      return mensaje;
    }

    return null;
  }

  String? validarEnteroPositivo(String? value, String mensaje) {
    if (value == null || value.trim().isEmpty) {
      return mensaje;
    }

    final numero = int.tryParse(value);

    if (numero == null || numero <= 0) {
      return 'Introduce un número mayor que 0';
    }

    return null;
  }

  String? validarEnteroPositivoOpcional(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final numero = int.tryParse(value);

    if (numero == null || numero <= 0) {
      return 'Introduce un número mayor que 0';
    }

    return null;
  }

  String? validarJugadoresMin(String? value) {
    return validarEnteroPositivo(
      value,
      'Introduce el mínimo de jugadores',
    );
  }

  String? validarJugadoresMax(String? value) {
    final errorBasico = validarEnteroPositivo(
      value,
      'Introduce el máximo de jugadores',
    );

    if (errorBasico != null) {
      return errorBasico;
    }

    final min = int.tryParse(jugadoresMinController.text);
    final max = int.tryParse(value!);

    if (min != null && max != null && max < min) {
      return 'El máximo no puede ser menor que el mínimo';
    }

    return null;
  }

  Widget construirCampoNombre() {
    return TextFormField(
      controller: nombreController,
      decoration: const InputDecoration(
        labelText: 'Nombre del juego',
        prefixIcon: Icon(Icons.extension),
      ),
      validator: (value) {
        return validarObligatorio(
          value,
          'Introduce el nombre del juego',
        );
      },
    );
  }

  Widget construirCampoTipo() {
    return TextFormField(
      controller: tipoController,
      decoration: const InputDecoration(
        labelText: 'Tipo/categoría (opcional)',
        prefixIcon: Icon(Icons.category),
      ),
    );
  }

  Widget construirCampoDuracion() {
    return TextFormField(
      controller: duracionController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Duración aprox. (opcional)',
        prefixIcon: Icon(Icons.timer),
      ),
      validator: validarEnteroPositivoOpcional,
    );
  }

  Widget construirCampoJugadoresMin() {
    return TextFormField(
      controller: jugadoresMinController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Jugadores mínimos',
        prefixIcon: Icon(Icons.person),
      ),
      validator: validarJugadoresMin,
    );
  }

  Widget construirCampoJugadoresMax() {
    return TextFormField(
      controller: jugadoresMaxController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Jugadores máximos',
        prefixIcon: Icon(Icons.groups),
      ),
      validator: validarJugadoresMax,
    );
  }

  Widget construirSwitchActivo() {
    return SwitchListTile(
      title: const Text('Juego activo'),
      subtitle: const Text(
        'Disponible en la ludoteca',
      ),
      value: activo,
      onChanged: (value) {
        setState(() {
          activo = value;
        });
      },
    );
  }

  Widget construirBotonGuardar() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: guardarJuego,
        icon: const Icon(
          Icons.save,
          size: 20,
        ),
        label: const Text(
          'Guardar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget construirCardFormulario() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              construirCampoNombre(),
              const SizedBox(height: 16),
              construirCampoTipo(),
              const SizedBox(height: 16),
              construirCampoDuracion(),
              const SizedBox(height: 16),
              construirCampoJugadoresMin(),
              const SizedBox(height: 16),
              construirCampoJugadoresMax(),
              const SizedBox(height: 8),
              construirSwitchActivo(),
              const SizedBox(height: 16),
              construirBotonGuardar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget construirContenido() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: construirCardFormulario(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar juego' : 'Nuevo juego'),
      ),
      body: AppBackground(
        child: construirContenido(),
      ),
    );
  }
}