import 'package:flutter/material.dart';

import '../../widgets/widgets.dart';

class ConfirmacionDatos {
  final String titulo;
  final String mensaje;
  final String textoConfirmar;

  const ConfirmacionDatos({
    required this.titulo,
    required this.mensaje,
    this.textoConfirmar = "Eliminar",
  });
}

class ConfirmarEliminacionScreen extends StatelessWidget {
  final ConfirmacionDatos datos;

  const ConfirmarEliminacionScreen({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(datos.titulo)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_forever_rounded, size: 96, color: Colors.red.shade700),
              const SizedBox(height: 20),
              Text(
                datos.mensaje,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              BotonPrincipal(
                texto: datos.textoConfirmar,
                peligro: true,
                onPressed: () => Navigator.pop(context, true),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
