import 'package:flutter/material.dart';

import '../models/juego.dart';
import '../services/juegos_service.dart';

class JuegoFormPage extends StatefulWidget {
  const JuegoFormPage({super.key});

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
      await JuegosService().insertarJuego(juego);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Juego guardado correctamente'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el juego: $e'),
        ),
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
        title: const Text('Añadir juego'),
      ),
      body: SingleChildScrollView(
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
    );
  }
}