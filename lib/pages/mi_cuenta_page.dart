import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/app_snackbar.dart';
import 'login_page.dart';

class MiCuentaPage extends StatefulWidget {
  const MiCuentaPage({super.key});

  @override
  State<MiCuentaPage> createState() => _MiCuentaPageState();
}

class _MiCuentaPageState extends State<MiCuentaPage> {
  late Future<void> futureDatosUsuario;

  String username = '';
  String rol = '';

  bool get esAdmin {
    return rol == 'admin';
  }

  @override
  void initState() {
    super.initState();
    futureDatosUsuario = cargarDatosUsuario();
  }

  Future<void> cargarDatosUsuario() async {
    final usernameSesion = await AuthService().obtenerUsernameActual();
    final rolSesion = await AuthService().obtenerRolActual();

    username = usernameSesion ?? 'Usuario desconocido';
    rol = rolSesion ?? 'Sin rol';
  }

  void editarMisDatos(BuildContext context) {
    AppSnackbar.mostrar(
      context,
      'Editar mis datos pendiente de implementar',
    );
  }

  void gestionarUsuarios(BuildContext context) {
    if (!esAdmin) {
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

  Future<void> cerrarSesion(BuildContext context) async {
    await AuthService().cerrarSesion();

    if (!context.mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  Widget construirAvatar() {
    return CircleAvatar(
      radius: 36,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      child: const Icon(
        Icons.person,
        size: 40,
      ),
    );
  }

  Widget construirCardUsuario() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            construirAvatar(),
            const SizedBox(height: 12),
            Text(
              username,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              rol,
              style: Theme.of(context).textTheme.bodySmall,
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
      subtitle: const Text('Modificar email o contraseña'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => editarMisDatos(context),
    );
  }

  Widget construirOpcionGestionUsuarios() {
    return ListTile(
      leading: const Icon(Icons.admin_panel_settings),
      title: const Text('Gestionar usuarios'),
      subtitle: const Text('Alta, edición y baja de usuarios'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => gestionarUsuarios(context),
    );
  }

  Widget construirOpcionCerrarSesion() {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: const Text('Cerrar sesión'),
      subtitle: const Text('Salir de la aplicación'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => cerrarSesion(context),
    );
  }

  Widget construirCardOpciones() {
    return Card(
      child: Column(
        children: [
          construirOpcionEditar(),
          if (esAdmin) const Divider(height: 1),
          if (esAdmin) construirOpcionGestionUsuarios(),
          const Divider(height: 1),
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

  Widget construirError(Object error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Error al cargar datos del usuario:\n$error',
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }

  Widget construirContenidoUsuario() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        construirCardUsuario(),
        const SizedBox(height: 12),
        construirCardOpciones(),
      ],
    );
  }

  Widget construirContenido(AsyncSnapshot<void> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return construirCarga();
    }

    if (snapshot.hasError) {
      return construirError(snapshot.error!);
    }

    return construirContenidoUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: futureDatosUsuario,
      builder: (context, snapshot) {
        return construirContenido(snapshot);
      },
    );
  }
}