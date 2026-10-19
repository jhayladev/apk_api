import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../router/router_apk.dart';
import '../../services/services.dart';
import '../../utils/mensajes.dart';
import '../../widgets/widgets.dart';
import '../shared/confirmar_eliminacion_screen.dart';

class ContactosScreen extends StatefulWidget {
  const ContactosScreen({super.key});

  @override
  State<ContactosScreen> createState() => _ContactosScreenState();
}

class _ContactosScreenState extends State<ContactosScreen> {
  late Future<List<Contact>> _contactos;

  @override
  void initState() {
    super.initState();
    _contactos = ContactsApi.obtenerContactos();
  }

  Future<void> _recargar() async {
    final nuevo = ContactsApi.obtenerContactos();
    setState(() => _contactos = nuevo);
    try {
      await nuevo;
    } catch (_) {}
  }

  Future<void> _abrirFormulario([Contact? contacto]) async {
    final guardado = await Navigator.pushNamed<bool>(
      context,
      RouterApk.contactoForm,
      arguments: contacto,
    );
    if (guardado == true) _recargar();
  }

  Future<void> _eliminar(Contact contacto) async {
    final confirmado = await Navigator.pushNamed<bool>(
      context,
      RouterApk.confirmarEliminacion,
      arguments: ConfirmacionDatos(
        titulo: "Eliminar contacto",
        mensaje: "¿Seguro que deseas eliminar a ${contacto.name}?",
      ),
    );
    if (confirmado != true || !mounted) return;
    try {
      final ok = await ContactsApi.eliminarContacto(contacto.id!);
      if (!mounted) return;
      if (ok) {
        Mensajes.exito(context, "Contacto eliminado exitosamente");
        _recargar();
      } else {
        Mensajes.error(context, "Error al eliminar el contacto");
      }
    } catch (_) {
      if (mounted) Mensajes.error(context, "No se pudo conectar con el servidor");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aplicación de contactos")),
      body: FutureBuilder<List<Contact>>(
        future: _contactos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CargandoVista();
          }
          if (snapshot.hasError) {
            return ErrorVista(
              mensaje: mensajeDeError(snapshot.error!),
              onReintentar: _recargar,
            );
          }
          final data = snapshot.data ?? const <Contact>[];
          if (data.isEmpty) {
            return const VaciaVista(
              mensaje: "No hay contactos registrados",
              icono: Icons.person_off_outlined,
            );
          }
          return RefreshIndicator(
            color: Colors.black,
            onRefresh: _recargar,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: data.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final contacto = data[index];
                return ContactoTile(
                  contacto: contacto,
                  onEditar: () => _abrirFormulario(contacto),
                  onEliminar: () => _eliminar(contacto),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'agregar_contacto',
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
