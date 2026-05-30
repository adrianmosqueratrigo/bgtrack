import 'package:flutter/material.dart';

class AppSnackbar {

  static const EdgeInsets margen = EdgeInsets.only(
    left: 30,
    right: 30,
    bottom: 50,
  );

  static void mostrar(
    BuildContext context,
    String mensaje,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: margen,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        content: Text(
          mensaje,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  static void mostrarError(
    BuildContext context,
    String mensaje,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: margen,
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(
          mensaje,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}