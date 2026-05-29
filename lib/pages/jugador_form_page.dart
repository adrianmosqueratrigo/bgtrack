import 'package:bgtrack/widgets/app_background.dart';
import 'package:flutter/material.dart';

import '../models/jugador.dart';
import '../services/jugadores_service.dart';
import '../utils/app_snackbar.dart';

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

    if (esEdicion) {
      nombreController.text = widget.jugador!.nombre;
      residenciaController.text = widget.jugador!.residencia ?? '';
      fechaNacimiento = widget.jugador!.fechaNacimiento;
      activo = widget.jugador!.activo;
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    residenciaController.dispose();
    super.dispose();
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
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        fechaNacimiento = fechaSeleccionada;
      });
    }
  }

  Future<void> guardarJugador() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final jugador = Jugador(
      id: widget.jugador?.id,
      nombre: nombreController.text.trim(),
      fechaNacimiento: fechaNacimiento,
      residencia: residenciaController.text.trim().isEmpty
          ? null
          : residenciaController.text.trim(),
      activo: activo,
    );



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
            ? 'Jugador actualizado correctamente'
            : 'Jugador guardado correctamente',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar jugador' : 'Nuevo jugador'),
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        return validarObligatorio(
                          value,
                          'Introduce el nombre del jugador',
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: seleccionarFechaNacimiento,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de nacimiento',
                          prefixIcon: Icon(Icons.calendar_month),
                        ),
                        child: Text(
                          textoFechaNacimiento(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: residenciaController,
                      decoration: const InputDecoration(
                        labelText: 'Residencia',
                        prefixIcon: Icon(Icons.location_on),
                        hintText: 'Opcional',
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Jugador activo'),
                      subtitle: const Text(
                        'Disponible para registrar nuevas partidas',
                      ),
                      value: activo,
                      onChanged: (value) {
                        setState(() {
                          activo = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: guardarJugador,
                        icon: const Icon(
                          Icons.save,
                          size: 20,
                        ),
                        label: const Text(
                          'Guardar',
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
      ),
    );
  }
}