import 'package:flutter/material.dart';

import '../models/models.dart';
import '../screens/screens.dart';

class RouterApk {
  static const String rutaInicial = "/";
  static const String contactoForm = "/contactos/formulario";
  static const String confirmarEliminacion = "/confirmar-eliminacion";
  static const String productoDetalle = "/productos/detalle";
  static const String productoForm = "/productos/formulario";

  static final Map<String, WidgetBuilder> rutasApk = {
    rutaInicial: (context) => const HomeScreen(),
  };

  static Route<dynamic>? generarRuta(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case contactoForm:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ContactoFormScreen(contacto: args as Contact?),
        );
      case confirmarEliminacion:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ConfirmarEliminacionScreen(datos: args as ConfirmacionDatos),
        );
      case productoDetalle:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ProductoDetalleScreen(productoId: args as int),
        );
      case productoForm:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ProductoFormScreen(producto: args as Product?),
        );
    }
    return null;
  }
}
