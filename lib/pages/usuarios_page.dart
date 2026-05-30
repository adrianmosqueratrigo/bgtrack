import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/usuarios_service.dart';
import 'usuario_form_page.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  late Future<List<Usuario>> futureUsuarios;

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  void cargarUsuarios() {
    futureUsuarios = UsuariosService().obtenerUsuarios();
  }

  Future<void> crearUsuario() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UsuarioFormPage()),
    );

    if (resultado == true) {
      setState(() {
        cargarUsuarios();
      });
    }
  }

  Future<void> editarUsuario(Usuario usuario) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UsuarioFormPage(usuario: usuario),
      ),
    );

    if (resultado == true) {
      setState(() {
        cargarUsuarios();
      });
    }
  }

  String textoNombreCompleto(Usuario usuario) {
    if (usuario.apellidos == null || usuario.apellidos!.trim().isEmpty) {
      return usuario.nombre;
    }

    return '${usuario.nombre} ${usuario.apellidos}';
  }

  String textoRol(String rol) {
    if (rol == 'admin') {
      return 'administrador';
    }
    return 'usuario';
  }

  Color colorEstado(bool activo) {
    return activo ? Colors.green : Colors.red;
  }

  IconData iconoEstado(bool activo) {
    return activo ? Icons.check_circle_outline_rounded : Icons.cancel_outlined;
  }

  Widget construirAvatarUsuario(Color primaryColor) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      child: const Icon(Icons.person_2_rounded, size: 28),
    );
  }

  Widget construirInformacionUsuario(
    Usuario usuario,
    Color secondaryTextColor,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            textoNombreCompleto(usuario),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            usuario.username,
            style: TextStyle(color: secondaryTextColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            usuario.email,
            style: TextStyle(color: secondaryTextColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            'Rol de ${textoRol(usuario.rol)}',
            style: TextStyle(color: secondaryTextColor),
          ),
        ],
      ),
    );
  }

  Widget construirAccionesUsuario(Usuario usuario) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          iconoEstado(usuario.activo),
          color: colorEstado(usuario.activo),
          size: 24,
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => editarUsuario(usuario),
          child: const Padding(
            padding: EdgeInsets.all(2),
            child: Icon(Icons.edit, size: 24),
          ),
        ),
      ],
    );
  }

  Widget construirCardUsuario(
    Usuario usuario,
    Color primaryColor,
    Color secondaryTextColor,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            construirAvatarUsuario(primaryColor),
            const SizedBox(width: 20),
            construirInformacionUsuario(usuario, secondaryTextColor),
            const SizedBox(width: 20),
            construirAccionesUsuario(usuario),
          ],
        ),
      ),
    );
  }

  Widget construirListaUsuarios(
    List<Usuario> usuarios,
    Color primaryColor,
    Color secondaryTextColor,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      itemCount: usuarios.length,
      itemBuilder: (context, index) {
        final usuario = usuarios[index];

        return construirCardUsuario(usuario, primaryColor, secondaryTextColor);
      },
    );
  }

  Widget construirCarga() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget construirError(Object error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Error al cargar usuarios:\n$error',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }

  Widget construirSinUsuarios() {
    return const Center(child: Text('No hay usuarios registrados.'));
  }

  Widget construirContenido(
    AsyncSnapshot<List<Usuario>> snapshot,
    Color primaryColor,
    Color secondaryTextColor,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return construirCarga();
    }

    if (snapshot.hasError) {
      return construirError(snapshot.error!);
    }

    final usuarios = snapshot.data ?? [];

    if (usuarios.isEmpty) {
      return construirSinUsuarios();
    }

    return construirListaUsuarios(usuarios, primaryColor, secondaryTextColor);
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    final Color secondaryTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar usuarios'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: IconButton(
              tooltip: 'Nuevo usuario',
              icon: const Icon(Icons.add_circle_outline_rounded, size: 32),
              onPressed: crearUsuario,
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Usuario>>(
        future: futureUsuarios,
        builder: (context, snapshot) {
          return construirContenido(snapshot, primaryColor, secondaryTextColor);
        },
      ),
    );
  }
}
