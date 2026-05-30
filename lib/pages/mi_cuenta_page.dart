import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/usuarios_service.dart';
import '../utils/app_snackbar.dart';
import 'login_page.dart';

class MiCuentaPage extends StatefulWidget {
  const MiCuentaPage({super.key});

  @override
  State<MiCuentaPage> createState() => _MiCuentaPageState();
}

class _MiCuentaPageState extends State<MiCuentaPage> {
  late Future<Usuario?> futureUsuario;

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  void cargarUsuario() {
    futureUsuario = obtenerUsuarioActual();
  }

  Future<Usuario?> obtenerUsuarioActual() async {
    final idUsuario = await AuthService().obtenerIdUsuarioActual();

    if (idUsuario == null) {
      throw Exception('No hay usuario iniciado');
    }

    return UsuariosService().obtenerUsuarioPorId(idUsuario);
  }

  bool esAdmin(Usuario usuario) {
    return usuario.rol == 'admin';
  }

  String textoNombreCompleto(Usuario usuario) {
    if (usuario.apellidos == null || usuario.apellidos!.trim().isEmpty) {
      return usuario.nombre;
    }

    return '${usuario.nombre} ${usuario.apellidos}';
  }

  void editarMisDatos() {
    AppSnackbar.mostrar(
      context,
      'Editar mis datos pendiente de implementar',
    );
  }

  void gestionarUsuarios(Usuario usuario) {
    if (!esAdmin(usuario)) {
      AppSnackbar.mostrarError(
        context,
        'No tienes permisos para gestionar usuarios',
      );
      return;
    }

    AppSnackbar.mostrar(
      context,
      'Gestión de usuarios pendiente de implementar',
    );
  }

  Future<void> cerrarSesion() async {
    await AuthService().cerrarSesion();

    if (!mounted) {
      return;
    }

    AppSnackbar.mostrar(
      context,
      'Sesión cerrada',
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  Widget construirAvatar(
    Color primaryColor,
  ) {
    return CircleAvatar(
      radius: 36,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      child: const Icon(
        Icons.person_2_rounded,
        size: 40,
      ),
    );
  }

  Widget construirNombreUsuario(
    Usuario usuario,
  ) {
    return Text(
      textoNombreCompleto(usuario),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget construirRolUsuario(
    Usuario usuario,
    Color secondaryTextColor,
  ) {
    return Text(
      'Rol de ${usuario.rol}',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: secondaryTextColor,
      ),
    );
  }

  Widget construirCardUsuario(
    Usuario usuario,
    Color primaryColor,
    Color secondaryTextColor,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          children: [
            construirAvatar(primaryColor),
            const SizedBox(height: 15),
            construirNombreUsuario(usuario),
            const SizedBox(height: 5),
            construirRolUsuario(
              usuario,
              secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget construirOpcionEditar() {
    return ListTile(
      leading: const Icon(Icons.edit),
      title: const Text('Editar mis datos'),
      subtitle: const Text('Datos o contraseña'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: editarMisDatos,
    );
  }

  Widget construirOpcionGestionUsuarios(
    Usuario usuario,
  ) {
    return ListTile(
      leading: const Icon(Icons.admin_panel_settings_rounded),
      title: const Text('Gestionar usuarios'),
      subtitle: const Text('Alta, edición y baja de usuarios'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        gestionarUsuarios(usuario);
      },
    );
  }

  Widget construirOpcionCerrarSesion() {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: const Text('Cerrar sesión'),
      subtitle: const Text('Salir de la aplicación'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: cerrarSesion,
    );
  }

  Widget construirCardOpciones(
    Usuario usuario,
  ) {
    return Card(
      child: Column(
        children: [
          construirOpcionEditar(),
          if (esAdmin(usuario)) const Divider(height: 5),
          if (esAdmin(usuario)) construirOpcionGestionUsuarios(usuario),
          const Divider(height: 5),
          construirOpcionCerrarSesion(),
        ],
      ),
    );
  }

  Widget construirCarga() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget construirError(
    Object error,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        'Error al cargar datos del usuario:\n$error',
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }

  Widget construirSinUsuario() {
    return const Center(
      child: Text('No se encontró el usuario.'),
    );
  }

  Widget construirListaCuenta(
    Usuario usuario,
    Color primaryColor,
    Color secondaryTextColor,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      children: [
        construirCardUsuario(
          usuario,
          primaryColor,
          secondaryTextColor,
        ),
        //const SizedBox(height: 10),
        construirCardOpciones(usuario),
      ],
    );
  }

  Widget construirContenido(
    AsyncSnapshot<Usuario?> snapshot,
    Color primaryColor,
    Color secondaryTextColor,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return construirCarga();
    }

    if (snapshot.hasError) {
      return construirError(snapshot.error!);
    }

    final usuario = snapshot.data;

    if (usuario == null) {
      return construirSinUsuario();
    }

    return construirListaCuenta(
      usuario,
      primaryColor,
      secondaryTextColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    final Color secondaryTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

    return FutureBuilder<Usuario?>(
      future: futureUsuario,
      builder: (context, snapshot) {
        return construirContenido(
          snapshot,
          primaryColor,
          secondaryTextColor,
        );
      },
    );
  }
}