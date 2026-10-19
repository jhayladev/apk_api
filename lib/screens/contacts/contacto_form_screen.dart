import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/mensajes.dart';
import '../../widgets/widgets.dart';

class ContactoFormScreen extends StatefulWidget {
  final Contact? contacto;

  const ContactoFormScreen({super.key, this.contacto});

  @override
  State<ContactoFormScreen> createState() => _ContactoFormScreenState();
}

class _ContactoFormScreenState extends State<ContactoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  bool _guardando = false;

  bool get _esEdicion => widget.contacto != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.contacto?.name);
    _email = TextEditingController(text: widget.contacto?.email);
    _phone = TextEditingController(text: widget.contacto?.phoneNumber);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  String? _requerido(String? valor) {
    return (valor == null || valor.trim().isEmpty) ? "Campo obligatorio" : null;
  }

  String? _correo(String? valor) {
    if (valor == null || valor.trim().isEmpty) return "Campo obligatorio";
    return valor.contains("@") ? null : "Correo no válido";
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    final contacto = Contact(
      id: widget.contacto?.id,
      name: _name.text.trim(),
      email: _email.text.trim(),
      phoneNumber: _phone.text.trim(),
    );
    try {
      final ok = _esEdicion
          ? await ContactsApi.editarContacto(contacto)
          : await ContactsApi.crearContacto(contacto);
      if (!mounted) return;
      if (ok) {
        Mensajes.exito(
          context,
          _esEdicion ? "Contacto editado exitosamente" : "Contacto agregado exitosamente",
        );
        Navigator.pop(context, true);
        return;
      }
      Mensajes.error(
        context,
        _esEdicion ? "Error al editar el contacto" : "Error al agregar el contacto",
      );
    } catch (_) {
      if (mounted) Mensajes.error(context, "No se pudo conectar con el servidor");
    }
    if (mounted) setState(() => _guardando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? "Editar contacto" : "Nuevo contacto")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 20,
              children: [
                CampoTexto(controller: _name, etiqueta: "Ingrese el nombre", validador: _requerido),
                CampoTexto(
                  controller: _email,
                  etiqueta: "Ingrese su correo",
                  teclado: TextInputType.emailAddress,
                  validador: _correo,
                ),
                CampoTexto(
                  controller: _phone,
                  etiqueta: "Ingrese su número de teléfono",
                  teclado: TextInputType.phone,
                  validador: _requerido,
                ),
                BotonPrincipal(
                  texto: _esEdicion ? "Editar contacto" : "Agregar contacto",
                  cargando: _guardando,
                  onPressed: _guardar,
                ),
                TextButton(
                  onPressed: _guardando ? null : () => Navigator.pop(context, false),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
