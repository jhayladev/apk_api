import 'package:flutter/material.dart';

class CargandoVista extends StatelessWidget {
  const CargandoVista({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: Colors.black));
  }
}

class ErrorVista extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const ErrorVista({super.key, required this.mensaje, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 56),
            const SizedBox(height: 12),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text("Reintentar"),
            ),
          ],
        ),
      ),
    );
  }
}

class VaciaVista extends StatelessWidget {
  final String mensaje;
  final IconData icono;

  const VaciaVista({super.key, required this.mensaje, this.icono = Icons.inbox_outlined});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 56, color: Colors.black38),
          const SizedBox(height: 12),
          Text(mensaje),
        ],
      ),
    );
  }
}

String mensajeDeError(Object error) {
  final texto = error.toString();
  return texto.startsWith("Exception: ") ? texto.substring(11) : "No se pudo conectar con el servidor";
}
