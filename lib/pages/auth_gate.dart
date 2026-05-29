import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_page.dart';
import 'login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<bool> futureSesion;

  @override
  void initState() {
    super.initState();
    futureSesion = AuthService().haySesionIniciada();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: futureSesion,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final haySesion = snapshot.data ?? false;

        if (haySesion) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}