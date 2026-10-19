import 'package:flutter/material.dart';

import '../contacts/contactos_screen.dart';
import '../products/productos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indice,
        children: const [ContactosScreen(), ProductosScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.contacts_outlined), label: "Contactos"),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), label: "Productos"),
        ],
      ),
    );
  }
}
