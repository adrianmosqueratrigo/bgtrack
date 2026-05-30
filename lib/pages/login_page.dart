import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/app_snackbar.dart';
import '../widgets/app_background.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool cargando = false;
  bool passwordVisible = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> iniciarSesion() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      await AuthService().iniciarSesion(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      AppSnackbar.mostrar(
        context,
        'Sesión iniciada correctamente',
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      AppSnackbar.mostrarError(
        context,
        'Usuario o contraseña incorrectos',
      );
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  String? validarObligatorio(String? value, String mensaje) {
    if (value == null || value.trim().isEmpty) {
      return mensaje;
    }

    return null;
  }

  void cambiarVisibilidadPassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  Widget construirTitulo() {
    return Column(
      children: [
        Text(
          'BGTrack',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
                fontSize: 46,
                letterSpacing: 2
              ),
        ),
        const SizedBox(height: 20),
        Text(
          'Iniciar sesión',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget construirCampoUsername() {
    return TextFormField(
      controller: usernameController,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Usuario',
        prefixIcon: Icon(Icons.person),
      ),
      validator: (value) {
        return validarObligatorio(
          value,
          'Introduce el usuario',
        );
      },
    );
  }

  Widget construirCampoPassword() {
    return TextFormField(
      controller: passwordController,
      obscureText: !passwordVisible,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) {
        iniciarSesion();
      },
      decoration: InputDecoration(
        labelText: 'Contraseña',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          onPressed: cambiarVisibilidadPassword,
          icon: Icon(
            passwordVisible
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
          ),
        ),
      ),
      validator: (value) {
        return validarObligatorio(
          value,
          'Introduce la contraseña',
        );
      },
    );
  }

  Widget construirBotonLogin() {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(
        horizontal: 25,
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: cargando ? null : iniciarSesion,
          icon: cargando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                )
              : const Icon(
                  Icons.login_rounded,
                  size: 22,
                ),
          label: Text(
            cargando ? 'Iniciando...' : 'Entrar',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget construirCardFormulario() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25,30,25,20),
        child: Column(
          children: [
            construirTitulo(),
            const SizedBox(height: 15),
            construirCampoUsername(),
            const SizedBox(height: 15),
            construirCampoPassword(),
          ],
        ),
      ),
    );
  }

  Widget construirContenidoFormulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 30,
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            const SizedBox(height: 150),
            construirCardFormulario(),
            const SizedBox(height: 15),
            construirBotonLogin(),
          ],
        ),
      ),
    );
  }

  Widget construirContenido() {
    return AppBackground(
      child: construirContenidoFormulario(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: construirContenido(),
    );
  }
}