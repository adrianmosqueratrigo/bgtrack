import 'package:flutter/material.dart';

import '../models/jugador.dart';
import '../services/jugadores_service.dart';
import '../utils/app_snackbar.dart';
import '../widgets/app_background.dart';

class JugadorFormPage extends StatefulWidget {
  final Jugador? jugador;

  const JugadorFormPage({
    super.key,
    this.jugador,
  });

  @override
  State<JugadorFormPage> createState() => _JugadorFormPageState();
}

class _JugadorFormPageState extends State<JugadorFormPage> {
  final formKey = GlobalKey<FormState>();

  final nombreController = TextEditingController();
  final residenciaController = TextEditingController();

  DateTime? fechaNacimiento;
  bool activo = true;

  bool get esEdicion {
    return widget.jugador != null;
  }

  @override
  void initState() {
    super.initState();
    cargarDatosJugador();
  }

  @override
  void dispose() {
    nombreController.dispose();
    residenciaController.dispose();
    super.dispose();
  }

  void cargarDatosJugador() {
    if (!esEdicion) {
      return;
    }

    final jugador = widget.jugador!;

    nombreController.text = jugador.nombre;
    residenciaController.text = jugador.residencia ?? '';
    fechaNacimiento = jugador.fechaNacimiento;
    activo = jugador.activo;
  }

  Jugador construirJugadorDesdeFormulario() {
    return Jugador(
      id: widget.jugador?.id,
      nombre: nombreController.text.trim(),
      fechaNacimiento: fechaNacimiento,
      residencia: residenciaController.text.trim().isEmpty
          ? null
          : residenciaController.text.trim(),
      activo: activo,
    );
  }

  Future<void> guardarJugador() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final jugador = construirJugadorDesdeFormulario();

    try {
      if (esEdicion) {
        await JugadoresService().actualizarJugador(jugador);
      } else {
        await JugadoresService().insertarJugador(jugador);
      }

      if (!mounted) {
        return;
      }

      AppSnackbar.mostrar(
        context,
        esEdicion
            ? 'Jugador actualizado'
            : 'Jugador guardado',
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      AppSnackbar.mostrarError(
        context,
        'Error al guardar el jugador',
      );
    }
  }

  String? validarObligatorio(String? value, String mensaje) {
    if (value == null || value.trim().isEmpty) {
      return mensaje;
    }

    return null;
  }

  String textoFechaNacimiento() {
    if (fechaNacimiento == null) {
      return 'Seleccionar fecha';
    }

    final dia = fechaNacimiento!.day.toString().padLeft(2, '0');
    final mes = fechaNacimiento!.month.toString().padLeft(2, '0');
    final anio = fechaNacimiento!.year.toString();

    return '$dia/$mes/$anio';
  }

  Future<void> seleccionarFechaNacimiento() async {
    final fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: fechaNacimiento ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (fechaSeleccionada == null) {
      return;
    }

    setState(() {
      fechaNacimiento = fechaSeleccionada;
    });
  }

  Widget construirCampoNombre() {
    return TextFormField(
      controller: nombreController,
      decoration: const InputDecoration(
        labelText: 'Nombre',
        prefixIcon: Icon(Icons.person_2_rounded),
      ),
      validator: (value) {
        return validarObligatorio(
          value,
          'Introduce el nombre del jugador',
        );
      },
    );
  }

  Widget construirCampoFechaNacimiento() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: seleccionarFechaNacimiento,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha de nacimiento',
          prefixIcon: Icon(Icons.calendar_month_rounded),
        ),
        child: Text(
          textoFechaNacimiento(),
        ),
      ),
    );
  }

  Widget construirCampoResidencia() {
    return TextFormField(
      controller: residenciaController,
      decoration: const InputDecoration(
        labelText: 'Residencia',
        prefixIcon: Icon(Icons.location_on_rounded),
        hintText: 'Opcional',
      ),
    );
  }

  Widget construirSwitchActivo() {
    return SwitchListTile(
      title: const Text('Jugador activo'),
      subtitle: const Text(
        'Está en activo',
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
        onPressed: guardarJugador,
        icon: const Icon(
          Icons.save_rounded,
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
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              construirCampoNombre(),
              const SizedBox(height: 10),
              construirCampoFechaNacimiento(),
              const SizedBox(height: 10),
              construirCampoResidencia(),
              const SizedBox(height: 5),
              construirSwitchActivo(),
              const SizedBox(height: 20),
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
        horizontal: 15,
        vertical: 10,
      ),
      child: construirCardFormulario(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar jugador' : 'Añadir jugador'),
      ),
      body: AppBackground(
        child: construirContenido(),
      ),
    );
  }
}