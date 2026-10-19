import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/mensajes.dart';
import '../../widgets/widgets.dart';

class ProductoFormScreen extends StatefulWidget {
  final Product? producto;

  const ProductoFormScreen({super.key, this.producto});

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titulo;
  late final TextEditingController _descripcion;
  late final TextEditingController _marca;
  late final TextEditingController _categoria;
  late final TextEditingController _precio;
  late final TextEditingController _stock;
  bool _guardando = false;

  bool get _esEdicion => widget.producto != null;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _titulo = TextEditingController(text: p?.title);
    _descripcion = TextEditingController(text: p?.description);
    _marca = TextEditingController(text: p?.brand);
    _categoria = TextEditingController(text: p?.category);
    _precio = TextEditingController(text: p == null ? "" : "${p.price}");
    _stock = TextEditingController(text: p == null ? "" : "${p.stock}");
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    _marca.dispose();
    _categoria.dispose();
    _precio.dispose();
    _stock.dispose();
    super.dispose();
  }

  String? _requerido(String? valor) {
    return (valor == null || valor.trim().isEmpty) ? "Campo obligatorio" : null;
  }

  String? _numero(String? valor) {
    if (valor == null || valor.trim().isEmpty) return "Campo obligatorio";
    final n = double.tryParse(valor.trim());
    if (n == null || n < 0) return "Número no válido";
    return null;
  }

  String? _entero(String? valor) {
    if (valor == null || valor.trim().isEmpty) return "Campo obligatorio";
    final n = int.tryParse(valor.trim());
    if (n == null || n < 0) return "Número entero no válido";
    return null;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    final base = widget.producto;
    final producto = Product(
      id: base?.id,
      title: _titulo.text.trim(),
      description: _descripcion.text.trim(),
      category: _categoria.text.trim(),
      brand: _marca.text.trim(),
      price: double.parse(_precio.text.trim()),
      stock: int.parse(_stock.text.trim()),
      discountPercentage: base?.discountPercentage ?? 0,
      rating: base?.rating ?? 0,
      thumbnail: base?.thumbnail ?? "",
      images: base?.images ?? const [],
      tags: base?.tags ?? const [],
    );
    try {
      final resultado = _esEdicion
          ? await ProductsApi.editarProducto(producto)
          : await ProductsApi.crearProducto(producto);
      if (!mounted) return;
      if (resultado != null) {
        Mensajes.exito(
          context,
          _esEdicion ? "Producto actualizado (simulado)" : "Producto creado (simulado)",
        );
        Navigator.pop(context, resultado);
        return;
      }
      Mensajes.error(
        context,
        _esEdicion ? "Error al actualizar el producto" : "Error al crear el producto",
      );
    } catch (_) {
      if (mounted) Mensajes.error(context, "No se pudo conectar con el servidor");
    }
    if (mounted) setState(() => _guardando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? "Editar producto" : "Nuevo producto")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 20,
              children: [
                CampoTexto(controller: _titulo, etiqueta: "Título", validador: _requerido),
                CampoTexto(controller: _descripcion, etiqueta: "Descripción", lineas: 3),
                CampoTexto(controller: _marca, etiqueta: "Marca"),
                CampoTexto(controller: _categoria, etiqueta: "Categoría", validador: _requerido),
                CampoTexto(
                  controller: _precio,
                  etiqueta: "Precio",
                  teclado: const TextInputType.numberWithOptions(decimal: true),
                  validador: _numero,
                ),
                CampoTexto(
                  controller: _stock,
                  etiqueta: "Stock",
                  teclado: TextInputType.number,
                  validador: _entero,
                ),
                BotonPrincipal(
                  texto: _esEdicion ? "Guardar cambios" : "Crear producto",
                  cargando: _guardando,
                  onPressed: _guardar,
                ),
                TextButton(
                  onPressed: _guardando ? null : () => Navigator.pop(context),
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
