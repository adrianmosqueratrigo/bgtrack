import 'package:flutter/material.dart';

import '../models/partida_detalle.dart';
import '../models/partida_resumen.dart';
import '../services/partidas_service.dart';
import '../utils/app_snackbar.dart';

class PartidaFormPage extends StatefulWidget {
  final PartidaResumen partida;

  const PartidaFormPage({super.key, required this.partida});

  @override
  State<PartidaFormPage> createState() => _PartidaFormPageState();
}

class _PartidaFormPageState extends State<PartidaFormPage> {
  final formKey = GlobalKey<FormState>();

  final duracionController = TextEditingController();
  final observacionesController = TextEditingController();

  late DateTime fechaHora;
  late String estado;
  bool cargandoDetalle = true;
  PartidaDetalle? detalle;

  @override
  void initState() {
    super.initState();

    fechaHora = widget.partida.fechaHora;
    estado = widget.partida.estado;
    duracionController.text = widget.partida.duracionMinutos?.toString() ?? '';

    cargarDetallePartida();
  }

  Future<void> cargarDetallePartida() async {
    try {
      final detallePartida = await PartidasService().obtenerDetallePartida(
        widget.partida.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        detalle = detallePartida;
        observacionesController.text = detallePartida?.notas ?? '';
        cargandoDetalle = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        cargandoDetalle = false;
      });

      AppSnackbar.mostrarError(
        context,
        'Error al cargar detalle de partida: $e',
      );

    }

  }

  @override
  void dispose() {
    duracionController.dispose();
    observacionesController.dispose();
    super.dispose();
  }

  String textoFechaHora() {
    final dia = fechaHora.day.toString().padLeft(2, '0');
    final mes = fechaHora.month.toString().padLeft(2, '0');
    final anio = fechaHora.year.toString();
    final hora = fechaHora.hour.toString().padLeft(2, '0');
    final minuto = fechaHora.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$anio · $hora:$minuto';
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

  Future<void> seleccionarFechaHora() async {
    final fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: fechaHora,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (fechaSeleccionada == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    final horaSeleccionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: fechaHora.hour, minute: fechaHora.minute),
    );

    if (horaSeleccionada == null) {
      return;
    }

    setState(() {
      fechaHora = DateTime(
        fechaSeleccionada.year,
        fechaSeleccionada.month,
        fechaSeleccionada.day,
        horaSeleccionada.hour,
        horaSeleccionada.minute,
      );
    });
  }

  Future<void> guardarPartida() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      await PartidasService().actualizarPartidaBasica(
        idPartida: widget.partida.id,
        fechaHora: fechaHora,
        duracionMinutos: duracionController.text.trim().isEmpty
            ? null
            : int.parse(duracionController.text.trim()),
        estado: estado,
        notas: observacionesController.text.trim().isEmpty
            ? null
            : observacionesController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      AppSnackbar.mostrar(
        context,
        'Partida actualizada correctamente',
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      AppSnackbar.mostrarError(
        context,
        'Error al actualizar la partida',
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar partida')),
      body: cargandoDetalle
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: widget.partida.nombreJuego,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Juego',
                            prefixIcon: Icon(Icons.extension),
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: seleccionarFechaHora,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Fecha y hora',
                              prefixIcon: Icon(Icons.calendar_month),
                            ),
                            child: Text(textoFechaHora()),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: duracionController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Duración en minutos',
                            prefixIcon: Icon(Icons.timer),
                            hintText: 'Opcional',
                          ),
                          validator: validarEnteroPositivoOpcional,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: estado,
                          decoration: const InputDecoration(
                            labelText: 'Estado',
                            prefixIcon: Icon(Icons.flag),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'finalizada',
                              child: Text('Finalizada'),
                            ),
                            DropdownMenuItem(
                              value: 'cancelada',
                              child: Text('Cancelada'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                estado = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: observacionesController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Observaciones',
                            prefixIcon: Icon(Icons.notes),
                            hintText: 'Opcional',
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: guardarPartida,
                            icon: const Icon(Icons.save, size: 20),
                            label: const Text(
                              'Guardar cambios',
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
    );
  }
}
