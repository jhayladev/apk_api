import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../router/router_apk.dart';
import '../../services/services.dart';
import '../../utils/mensajes.dart';
import '../../widgets/widgets.dart';
import '../shared/confirmar_eliminacion_screen.dart';

class ProductoDetalleScreen extends StatefulWidget {
  final int productoId;

  const ProductoDetalleScreen({super.key, required this.productoId});

  @override
  State<ProductoDetalleScreen> createState() => _ProductoDetalleScreenState();
}

class _ProductoDetalleScreenState extends State<ProductoDetalleScreen> {
  Product? _producto;
  String? _error;
  bool _cargando = true;
  bool _eliminando = false;
  ProductoResultado? _resultado;
  int _imagenActual = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final producto = await ProductsApi.obtenerProducto(widget.productoId);
      if (!mounted) return;
      setState(() {
        _producto = producto;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = mensajeDeError(e);
        _cargando = false;
      });
    }
  }

  Future<void> _editar() async {
    final editado = await Navigator.pushNamed<Product>(
      context,
      RouterApk.productoForm,
      arguments: _producto,
    );
    if (editado == null || !mounted) return;
    setState(() {
      _producto = editado;
      _resultado = ProductoResultado(producto: editado);
    });
  }

  Future<void> _eliminar() async {
    final producto = _producto!;
    final confirmado = await Navigator.pushNamed<bool>(
      context,
      RouterApk.confirmarEliminacion,
      arguments: ConfirmacionDatos(
        titulo: "Eliminar producto",
        mensaje: "¿Seguro que deseas eliminar \"${producto.title}\"?",
      ),
    );
    if (confirmado != true || !mounted) return;
    setState(() => _eliminando = true);
    try {
      final ok = await ProductsApi.eliminarProducto(producto.id!);
      if (!mounted) return;
      if (ok) {
        Mensajes.exito(context, "Producto eliminado (simulado)");
        Navigator.pop(context, const ProductoResultado(eliminado: true));
        return;
      }
      Mensajes.error(context, "Error al eliminar el producto");
    } catch (_) {
      if (mounted) Mensajes.error(context, "No se pudo conectar con el servidor");
    }
    if (mounted) setState(() => _eliminando = false);
  }

  @override
  Widget build(BuildContext context) {
    final producto = _producto;
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _resultado);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(producto?.title ?? "Producto", overflow: TextOverflow.ellipsis),
          actions: [
            if (producto != null) ...[
              IconButton(onPressed: _eliminando ? null : _editar, icon: const Icon(Icons.edit)),
              IconButton(onPressed: _eliminando ? null : _eliminar, icon: const Icon(Icons.delete)),
            ],
          ],
        ),
        body: _cuerpo(producto),
      ),
    );
  }

  Widget _cuerpo(Product? producto) {
    if (_cargando) return const CargandoVista();
    if (_error != null || producto == null) {
      return ErrorVista(mensaje: _error ?? "Producto no disponible", onReintentar: _cargar);
    }
    final imagenes = producto.images.isEmpty
        ? [if (producto.imagenPrincipal.isNotEmpty) producto.imagenPrincipal]
        : producto.images;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Container(
          height: 280,
          color: Colors.black12,
          child: imagenes.isEmpty
              ? const ImagenRed(url: "")
              : PageView.builder(
                  itemCount: imagenes.length,
                  onPageChanged: (i) => setState(() => _imagenActual = i),
                  itemBuilder: (_, i) => ImagenRed(url: imagenes[i]),
                ),
        ),
        if (imagenes.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < imagenes.length; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _imagenActual ? Colors.black : Colors.black26,
                    ),
                  ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                producto.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              if (producto.brand.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(producto.brand, style: const TextStyle(color: Colors.black54)),
                ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "\$${producto.precioFinal.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  if (producto.discountPercentage > 0) ...[
                    const SizedBox(width: 10),
                    Text(
                      "\$${producto.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.black45,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "-${producto.discountPercentage.toStringAsFixed(0)}%",
                      style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber),
                  Text(" ${producto.rating.toStringAsFixed(1)}"),
                  const SizedBox(width: 20),
                  const Icon(Icons.inventory_2_outlined, size: 20),
                  Text("  ${producto.stock} en stock"),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (producto.category.isNotEmpty) Chip(label: Text(producto.category)),
                  for (final tag in producto.tags) Chip(label: Text(tag)),
                ],
              ),
              const SizedBox(height: 16),
              Text(producto.description, style: const TextStyle(fontSize: 15, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
