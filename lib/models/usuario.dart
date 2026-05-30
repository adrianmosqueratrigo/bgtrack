class Usuario {
  int? id;
  String rol;
  String nombre;
  String apellidos;
  String username;
  String email;
  String passwordHash;
  bool activo;
  DateTime? ultimoLogin;
  DateTime? fechaRegistro;

  Usuario({
    this.id,
    required this.rol,
    required this.nombre,
    required this.apellidos,
    required this.username,
    required this.email,
    required this.passwordHash,
    this.activo = true,
    this.ultimoLogin,
    this.fechaRegistro,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      rol: map['rol'],
      nombre: map['nombre'],
      apellidos: map['apellidos'],
      username: map['username'],
      email: map['email'],
      passwordHash: map['password_hash'],
      activo: map['activo'] == 1 || map['activo'] == true,
      ultimoLogin: map['ultimo_login'] != null
          ? DateTime.parse(map['ultimo_login'].toString())
          : null,
      fechaRegistro: map['fecha_registro'] != null
          ? DateTime.parse(map['fecha_registro'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rol': rol,
      'nombre': nombre,
      'apellidos': apellidos,
      'username': username,
      'email': email,
      'password_hash': passwordHash,
      'activo': activo ? 1 : 0,
      'ultimo_login': ultimoLogin?.toIso8601String(),
      'fecha_registro': fechaRegistro?.toIso8601String(),
    };
  }
}