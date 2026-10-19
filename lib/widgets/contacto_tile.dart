import 'package:flutter/material.dart';

import '../models/models.dart';

class ContactoTile extends StatelessWidget {
  final Contact contacto;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const ContactoTile({
    super.key,
    required this.contacto,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final inicial = contacto.name.isEmpty ? "?" : contacto.name[0].toUpperCase();
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: Text(inicial),
      ),
      title: Text(contacto.name),
      subtitle: Text("${contacto.email}\n${contacto.phoneNumber}"),
      isThreeLine: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: onEditar, icon: const Icon(Icons.edit)),
          IconButton(onPressed: onEliminar, icon: const Icon(Icons.delete)),
        ],
      ),
    );
  }
}
