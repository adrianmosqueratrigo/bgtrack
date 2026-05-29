import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart';
import 'usuarios_service.dart';

class AuthService {
  static const String claveIdUsuario = 'id_usuario';
  static const String claveUsername = 'username';
  static const String claveRol = 'rol';

  Future<Usuario> iniciarSesion({
    required String username,
    required String password,
  }) async {
    final usuario = await UsuariosService().obtenerUsuarioPorUsername(
      username.trim(),
    );

    if (usuario == null) {
      throw Exception('Usuario o contraseña incorrectos');
    }

    if (!usuario.activo) {
      throw Exception('El usuario está inactivo');
    }

    if (password.trim() != usuario.passwordHash) {
      throw Exception('Usuario o contraseña incorrectos');
    }

    await UsuariosService().actualizarUltimoLogin(usuario.id!);
    await guardarSesion(usuario);

    return usuario;
  }

  Future<void> guardarSesion(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(claveIdUsuario, usuario.id!);
    await prefs.setString(claveUsername, usuario.username);
    await prefs.setString(claveRol, usuario.rol);
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(claveIdUsuario);
    await prefs.remove(claveUsername);
    await prefs.remove(claveRol);
  }

  Future<bool> haySesionIniciada() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.containsKey(claveIdUsuario);
  }

  Future<int?> obtenerIdUsuarioActual() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(claveIdUsuario);
  }

  Future<String?> obtenerUsernameActual() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(claveUsername);
  }

  Future<String?> obtenerRolActual() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(claveRol);
  }

  Future<bool> esAdmin() async {
    final rol = await obtenerRolActual();

    return rol == 'admin';
  }
}