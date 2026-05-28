import 'dart:convert';

class PartidaDetalle {
  int id;
  String nombreJuego;
  String usernameUsuario;
  DateTime fechaHora;
  int? duracionMinutos;
  String estado;
  String? notas;

  PartidaDetalle({
    required this.id,
    required this.nombreJuego,
    required this.usernameUsuario,
    required this.fechaHora,
    this.duracionMinutos,
    required this.estado,
    this.notas,
  });

  static String? convertirTexto(dynamic valor) {
    if (valor == null) {
      return null;
    }

    if (valor is String) {
      return valor;
    }

    try {
      final bytes = valor.toBytes();
      return utf8.decode(List<int>.from(bytes));
    } catch (_) {
      return valor.toString();
    }
  }

  factory PartidaDetalle.fromMap(Map<String, dynamic> map) {
    return PartidaDetalle(
      id: map['id'],
      nombreJuego: convertirTexto(map['nombre_juego']) ?? '',
      usernameUsuario: convertirTexto(map['username_usuario']) ?? '',
      fechaHora: DateTime.parse(map['fecha_hora'].toString()),
      duracionMinutos: map['duracion_minutos'],
      estado: convertirTexto(map['estado']) ?? '',
      notas: convertirTexto(map['notas']),
    );
  }
}