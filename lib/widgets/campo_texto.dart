import 'package:flutter/material.dart';

class CampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final String etiqueta;
  final TextInputType teclado;
  final int lineas;
  final String? Function(String?)? validador;

  const CampoTexto({
    super.key,
    required this.controller,
    required this.etiqueta,
    this.teclado = TextInputType.text,
    this.lineas = 1,
    this.validador,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: teclado,
      maxLines: lineas,
      validator: validador,
      decoration: InputDecoration(labelText: etiqueta),
    );
  }
}
