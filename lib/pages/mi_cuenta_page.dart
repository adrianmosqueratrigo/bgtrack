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
    futureUsuario = cargarUsuario();
  }

  Future<Usuario?> cargarUsuario() async {
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
    if (usuario.apellidos.isEmpty || usuario.apellidos!.trim().isEmpty) {
      return usuario.nombre;
    }

    return '${usuario.nombre} ${usuario.apellidos}';
  }

  String textoApellidos(String? apellidos) {
    if (apellidos == null || apellidos.trim().isEmpty) {
      return 'Sin apellidos';
    }

    return apellidos;
  }

  String textoRol(String rol) {
    if (rol == 'admin') {
      return 'Administrador';
    }

    return 'Usuario';
  }

  String textoEstado(bool activo) {
    return activo ? 'Activo' : 'Inactivo';
  }

  String textoFecha(DateTime? fecha) {
    if (fecha == null) {
      return 'Sin datos';
    }

    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$anio · $hora:$minuto';
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

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  Widget construirAvatar(Color primaryColor) {
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
            const SizedBox(height: 10),
            Text(
              textoNombreCompleto(usuario),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              'Permisos de: ${usuario.rol}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

/*
  Widget construirCardDetalleUsuario(Usuario usuario) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Table(
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          children: [
            construirFilaDetalle(
              'Nombre',
              usuario.nombre,
            ),
            construirFilaDetalle(
              'Apellidos',
              textoApellidos(usuario.apellidos),
            ),
            construirFilaDetalle(
              'Usuario',
              usuario.username,
            ),
            construirFilaDetalle(
              'Email',
              usuario.email,
            ),
            construirFilaDetalle(
              'Rol',
              textoRol(usuario.rol),
            ),
            construirFilaDetalle(
              'Estado',
              textoEstado(usuario.activo),
            ),
            construirFilaDetalle(
              'Último login',
              textoFecha(usuario.ultimoLogin),
            ),
            construirFilaDetalle(
              'Registro',
              textoFecha(usuario.fechaRegistro),
            ),
          ],
        ),
      ),
    );
  }
*/
/*
  TableRow construirFilaDetalle(String titulo, String valor) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            right: 10,
            bottom: 10,
          ),
          child: Text(
            titulo,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 10,
          ),
          child: Text(
            valor,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
*/
  Widget construirOpcionEditar() {
    return ListTile(
      leading: const Icon(Icons.edit),
      title: const Text('Editar mis datos'),
      subtitle: const Text('Modificar email o contraseña'),
      trailing: const Icon(Icons.chevron_right),
      onTap: editarMisDatos,
    );
  }

  Widget construirOpcionGestionUsuarios(Usuario usuario) {
    return ListTile(
      leading: const Icon(Icons.admin_panel_settings),
      title: const Text('Gestionar usuarios'),
      subtitle: const Text('Alta, edición y baja de usuarios'),
      trailing: const Icon(Icons.chevron_right),
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
      trailing: const Icon(Icons.chevron_right),
      onTap: cerrarSesion,
    );
  }

  Widget construirCardOpciones(Usuario usuario) {
    return Card(
      child: Column(
        children: [
          construirOpcionEditar(),
          if (esAdmin(usuario)) const Divider(height: 1),
          if (esAdmin(usuario)) construirOpcionGestionUsuarios(usuario),
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

  Widget construirContenidoUsuario(
    Usuario usuario,
    Color primaryColor,
    Color secondaryTextColor,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      children: [
        construirCardUsuario(
          usuario,
          primaryColor,
          secondaryTextColor,
        ),
        //const SizedBox(height: 10),
        //construirCardDetalleUsuario(usuario),
        const SizedBox(height: 10),
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

    return construirContenidoUsuario(
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