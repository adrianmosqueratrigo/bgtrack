import 'package:bgtrack/widgets/app_background.dart';
import 'package:flutter/material.dart';

import '../models/juego.dart';
import '../services/juegos_service.dart';
import '../utils/app_snackbar.dart';

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

    if (esEdicion) {
      nombreController.text = widget.juego!.nombre;
      tipoController.text = widget.juego!.tipo ?? '';
      duracionController.text =
          widget.juego!.duracionEstimadaMinutos?.toString() ?? '';
      jugadoresMinController.text = widget.juego!.jugadoresMin.toString();
      jugadoresMaxController.text = widget.juego!.jugadoresMax.toString();
      activo = widget.juego!.activo;
    }
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

  Future<void> guardarJuego() async {
    
    if (!formKey.currentState!.validate()) {
      return;
    }

    final juego = Juego(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar juego' : 'Nuevo juego'),
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
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
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: tipoController,
                      decoration: const InputDecoration(
                        labelText: 'Tipo/categoría (opcional)',
                        prefixIcon: Icon(Icons.category),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: duracionController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Duración aprox. (opcional)',
                        prefixIcon: Icon(Icons.timer),
                      ),
                      validator: validarEnteroPositivoOpcional,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: jugadoresMinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jugadores mínimos',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        return validarEnteroPositivo(
                          value,
                          'Introduce el mínimo de jugadores',
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: jugadoresMaxController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jugadores máximos',
                        prefixIcon: Icon(Icons.groups),
                      ),
                      validator: validarJugadoresMax,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
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
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
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