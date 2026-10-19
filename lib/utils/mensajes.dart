import 'package:flutter/material.dart';

class Mensajes {
  static void exito(BuildContext context, String texto) => _mostrar(context, texto, Colors.green.shade700);

  static void error(BuildContext context, String texto) => _mostrar(context, texto, Colors.red.shade700);

  static void _mostrar(BuildContext context, String texto, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
