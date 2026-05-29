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