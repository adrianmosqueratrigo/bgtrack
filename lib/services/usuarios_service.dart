import '../database/connection.dart';
import '../models/usuario.dart';

class UsuariosService {

  Future<Usuario?> obtenerUsuarioPorUsername(String username) async {
    final conexion = await DatabaseConnection.getConnection();

    try {
      final resultados = await conexion.query(
        '''
        SELECT 
          id,
          rol,
          nombre,
          apellidos,
          username,
          email,
          password_hash,
          activo,
          ultimo_login,
          fecha_registro
        FROM usuarios
        WHERE username = ?
        LIMIT 1
        ''',
        [username],
      );

      if (resultados.isEmpty) {
        return null;
      }

      return Usuario.fromMap(resultados.first.fields);
    } finally {
      await conexion.close();
    }
  }

  Future<Usuario?> obtenerUsuarioPorId(int idUsuario) async {
    final conexion = await DatabaseConnection.getConnection();

    try {
      final resultados = await conexion.query(
        '''
        SELECT 
          id,
          rol,
          nombre,
          apellidos,
          username,
          email,
          password_hash,
          activo,
          ultimo_login,
          fecha_registro
        FROM usuarios
        WHERE id = ?
        LIMIT 1
        ''',
        [idUsuario],
      );

      if (resultados.isEmpty) {
        return null;
      }

      return Usuario.fromMap(resultados.first.fields);
    } finally {
      await conexion.close();
    }
  }

  Future<List<Usuario>> obtenerUsuarios() async {
    final conexion = await DatabaseConnection.getConnection();

    try {
      final resultados = await conexion.query(
        '''
        SELECT 
          id,
          rol,
          nombre,
          apellidos,
          username,
          email,
          password_hash,
          activo,
          ultimo_login,
          fecha_registro
        FROM usuarios
        ORDER BY nombre, apellidos, username
        ''',
      );

      return resultados.map((row) {
        return Usuario.fromMap(row.fields);
      }).toList();
    } finally {
      await conexion.close();
    }
  }

  Future<void> insertarUsuario(Usuario usuario) async {
    final conexion = await DatabaseConnection.getConnection();

    try {
      await conexion.query(
        '''
        INSERT INTO usuarios (
          rol,
          nombre,
          apellidos,
          username,
          email,
          password_hash,
          activo
        )
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          usuario.rol,
          usuario.nombre,
          usuario.apellidos,
          usuario.username,
          usuario.email,
          usuario.passwordHash,
          usuario.activo,
        ],
      );
    } finally {
      await conexion.close();
    }
  }

  Future<void> actualizarUsuario(Usuario usuario) async {
    final conexion = await DatabaseConnection.getConnection();

    try {
      await conexion.query(
        '''
        UPDATE usuarios
        SET 
          rol = ?,
          nombre = ?,
          apellidos = ?,
          username = ?,
          email = ?,
          password_hash = ?,
          activo = ?
        WHERE id = ?
        ''',
        [
          usuario.rol,
          usuario.nombre,
          usuario.apellidos,
          usuario.username,
          usuario.email,
          usuario.passwordHash,
          usuario.activo,
          usuario.id,
        ],
      );
    } finally {
      await conexion.close();
    }
  }

  Future<void> actualizarUltimoLogin(int idUsuario) async {
    final conexion = await DatabaseConnection.getConnection();

    try {
      await conexion.query(
        '''
        UPDATE usuarios
        SET ultimo_login = NOW()
        WHERE id = ?
        ''',
        [idUsuario],
      );
    } finally {
      await conexion.close();
    }
  }

}
