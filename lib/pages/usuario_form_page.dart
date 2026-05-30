import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/usuarios_service.dart';
import '../utils/app_snackbar.dart';
import '../widgets/app_background.dart';

class UsuarioFormPage extends StatefulWidget {
  final Usuario? usuario;
  final bool esMiPerfil;

  const UsuarioFormPage({
    super.key,
    this.usuario,
    this.esMiPerfil = false,
  });

  @override
  State<UsuarioFormPage> createState() => _UsuarioFormPageState();
}

class _UsuarioFormPageState extends State<UsuarioFormPage> {
  final formKey = GlobalKey<FormState>();

  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmarPasswordController = TextEditingController();

  String rol = 'usuario';
  bool activo = true;

  bool passwordVisible = false;
  bool confirmarPasswordVisible = false;

  bool get esEdicion {
    return widget.usuario != null;
  }

  bool get puedeEditarDatosAdmin {
    return !widget.esMiPerfil;
  }

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidosController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmarPasswordController.dispose();
    super.dispose();
  }

  void cargarDatosUsuario() {
    if (!esEdicion) {
      return;
    }

    final usuario = widget.usuario!;

    nombreController.text = usuario.nombre;
    apellidosController.text = usuario.apellidos ?? '';
    usernameController.text = usuario.username;
    emailController.text = usuario.email;
    rol = usuario.rol;
    activo = usuario.activo;
  }

  Usuario construirUsuarioDesdeFormulario() {
    final passwordTexto = passwordController.text.trim();

    return Usuario(
      id: widget.usuario?.id,
      rol: puedeEditarDatosAdmin ? rol : widget.usuario!.rol,
      nombre: nombreController.text.trim(),
      apellidos: apellidosController.text.trim().isEmpty
          ? null
          : apellidosController.text.trim(),
      username: puedeEditarDatosAdmin
          ? usernameController.text.trim()
          : widget.usuario!.username,
      email: emailController.text.trim(),
      passwordHash: passwordTexto.isEmpty && esEdicion
          ? widget.usuario!.passwordHash
          : passwordTexto,
      activo: puedeEditarDatosAdmin ? activo : widget.usuario!.activo,
      ultimoLogin: widget.usuario?.ultimoLogin,
      fechaRegistro: widget.usuario?.fechaRegistro,
    );
  }

  Future<void> guardarUsuario() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final usuario = construirUsuarioDesdeFormulario();

    try {
      if (esEdicion) {
        await UsuariosService().actualizarUsuario(usuario);
      } else {
        await UsuariosService().insertarUsuario(usuario);
      }

      if (!mounted) {
        return;
      }

      AppSnackbar.mostrar(
        context,
        widget.esMiPerfil
            ? 'Datos actualizados'
            : esEdicion
                ? 'Usuario actualizado'
                : 'Usuario guardado',
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      AppSnackbar.mostrarError(
        context,
        widget.esMiPerfil
            ? 'Error al actualizar mis datos'
            : 'Error al guardar el usuario',
      );
    }
  }

  String? validarObligatorio(String? value, String mensaje) {
    if (value == null || value.trim().isEmpty) {
      return mensaje;
    }

    return null;
  }

  String? validarEmail(String? value) {
    final errorObligatorio = validarObligatorio(
      value,
      'Introduce el email',
    );

    if (errorObligatorio != null) {
      return errorObligatorio;
    }

    final email = value!.trim();

    if (!email.contains('@') || !email.contains('.')) {
      return 'Introduce un email válido';
    }

    return null;
  }

  String? validarPassword(String? value) {
    final password = value?.trim() ?? '';

    if (!esEdicion && password.isEmpty) {
      return 'Introduce la contraseña';
    }

    if (password.isNotEmpty && password.length < 4) {
      return 'La contraseña debe tener al menos 4 caracteres';
    }

    return null;
  }

  String? validarConfirmarPassword(String? value) {
    final password = passwordController.text.trim();
    final confirmarPassword = value?.trim() ?? '';

    if (!esEdicion && confirmarPassword.isEmpty) {
      return 'Confirma la contraseña';
    }

    if (password.isNotEmpty && confirmarPassword != password) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  void cambiarVisibilidadPassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  void cambiarVisibilidadConfirmarPassword() {
    setState(() {
      confirmarPasswordVisible = !confirmarPasswordVisible;
    });
  }

  Widget construirCampoUsername() {
    return TextFormField(
      controller: usernameController,
      enabled: puedeEditarDatosAdmin,
      decoration: const InputDecoration(
        labelText: 'Username',
        prefixIcon: Icon(Icons.account_circle_rounded),
      ),
      validator: (value) {
        return validarObligatorio(
          value,
          'Introduce el username',
        );
      },
    );
  }

  Widget construirCampoEmail() {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email_rounded),
      ),
      validator: validarEmail,
    );
  }

  Widget construirCampoNombre() {
    return TextFormField(
      controller: nombreController,
      decoration: const InputDecoration(
        labelText: 'Nombre',
        prefixIcon: Icon(Icons.person_2_rounded),
      ),
      validator: (value) {
        return validarObligatorio(
          value,
          'Introduce el nombre',
        );
      },
    );
  }

  Widget construirCampoApellidos() {
    return TextFormField(
      controller: apellidosController,
      decoration: const InputDecoration(
        labelText: 'Apellidos (opcional)',
        prefixIcon: Icon(Icons.badge_rounded),
      ),
    );
  }

  Widget construirCampoPassword() {
    return TextFormField(
      controller: passwordController,
      obscureText: !passwordVisible,
      decoration: InputDecoration(
        labelText: esEdicion ? 'Nueva contraseña (opcional)' : 'Contraseña',
        prefixIcon: const Icon(Icons.lock_rounded),
        //hintText: esEdicion ? 'Opcional' : null,
        suffixIcon: IconButton(
          onPressed: cambiarVisibilidadPassword,
          icon: Icon(
            passwordVisible
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
          ),
        ),
      ),
      validator: validarPassword,
    );
  }

  Widget construirCampoConfirmarPassword() {
    return TextFormField(
      controller: confirmarPasswordController,
      obscureText: !confirmarPasswordVisible,
      decoration: InputDecoration(
        labelText: esEdicion
            ? 'Confirmar contraseña (opcional)'
            : 'Confirmar contraseña',
        prefixIcon: const Icon(Icons.lock_rounded),
        //hintText: esEdicion ? 'Opcional' : null,
        suffixIcon: IconButton(
          onPressed: cambiarVisibilidadConfirmarPassword,
          icon: Icon(
            confirmarPasswordVisible
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
          ),
        ),
      ),
      validator: validarConfirmarPassword,
    );
  }

  Widget construirCampoRol() {
    return DropdownButtonFormField<String>(
      initialValue: rol,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Rol',
        prefixIcon: Icon(Icons.admin_panel_settings_rounded),
      ),
      items: const [
        DropdownMenuItem(
          value: 'admin',
          child: Text('Administrador'),
        ),
        DropdownMenuItem(
          value: 'usuario',
          child: Text('Usuario'),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            rol = value;
          });
        }
      },
    );
  }

  Widget construirSwitchActivo() {
    return SwitchListTile(
      title: const Text('Usuario habilitado'),
      subtitle: const Text(
        'Permitir inicio de sesión',
      ),
      value: activo,
      onChanged: (value) {
        setState(() {
          activo = value;
        });
      },
    );
  }

  Widget construirBotonGuardar() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: guardarUsuario,
        icon: const Icon(
          Icons.save_rounded,
          size: 20,
        ),
        label: const Text(
          'Guardar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget construirCardFormulario() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 15,
        ),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              construirCampoNombre(),
              const SizedBox(height: 10),
              construirCampoApellidos(),
              const SizedBox(height: 10),
              construirCampoUsername(),
              const SizedBox(height: 10),
              construirCampoEmail(),
              const SizedBox(height: 10),
              construirCampoPassword(),
              const SizedBox(height: 10),
              construirCampoConfirmarPassword(),
              if (puedeEditarDatosAdmin) ...[
                const SizedBox(height: 10),
                construirCampoRol(),
                const SizedBox(height: 5),
                construirSwitchActivo(),
              ],
              const SizedBox(height: 20),
              construirBotonGuardar(),

            ],
          ),
        ),
      ),
    );
  }

  Widget construirContenido() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      child: construirCardFormulario(),
    );
  }

  String tituloPagina() {
    if (widget.esMiPerfil) {
      return 'Editar mis datos';
    }

    if (esEdicion) {
      return 'Editar usuario';
    }

    return 'Nuevo usuario';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tituloPagina()),
        
      ),
      body: AppBackground(
        child: construirContenido(),
      ),
    );
  }
}