import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../router/router_apk.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class _Orden {
  final String etiqueta;
  final String? campo;
  final String direccion;

  const _Orden(this.etiqueta, this.campo, this.direccion);
}

const List<_Orden> _ordenes = [
  _Orden("Relevancia", null, "asc"),
  _Orden("Precio: menor a mayor", "price", "asc"),
  _Orden("Precio: mayor a menor", "price", "desc"),
  _Orden("Título: A-Z", "title", "asc"),
];

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  static const int _limite = 20;

  final _scroll = ScrollController();
  final _busqueda = TextEditingController();
  Timer? _debounce;

  final List<Product> _productos = [];
  List<ProductCategory> _categorias = [];
  String? _categoria;
  _Orden _orden = _ordenes.first;
  int _total = 0;
  bool _cargando = true;
  bool _cargandoMas = false;
  String? _error;

  bool get _hayMas => _productos.length < _total;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_alDesplazar);
    _cargarCategorias();
    _cargar();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _busqueda.dispose();
    super.dispose();
  }

  void _alDesplazar() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      _cargarMas();
    }
  }

  Future<void> _cargarCategorias() async {
    try {
      final categorias = await ProductsApi.obtenerCategorias();
      if (mounted) setState(() => _categorias = categorias);
    } catch (_) {}
  }

  Future<ProductsPage> _pedir(int skip) {
    return ProductsApi.obtenerProductos(
      limit: _limite,
      skip: skip,
      busqueda: _busqueda.text,
      categoria: _categoria,
      ordenarPor: _orden.campo,
      orden: _orden.direccion,
    );
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final pagina = await _pedir(0);
      if (!mounted) return;
      setState(() {
        _productos
          ..clear()
          ..addAll(pagina.products);
        _total = pagina.total;
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

  Future<void> _cargarMas() async {
    if (_cargando || _cargandoMas || !_hayMas) return;
    setState(() => _cargandoMas = true);
    try {
      final pagina = await _pedir(_productos.length);
      if (!mounted) return;
      setState(() {
        _productos.addAll(pagina.products);
        _total = pagina.total;
      });
    } catch (_) {}
    if (mounted) setState(() => _cargandoMas = false);
  }

  void _alBuscar(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _cargar);
  }

  void _elegirCategoria(String? slug) {
    setState(() => _categoria = slug);
    _cargar();
  }

  void _elegirOrden(_Orden orden) {
    setState(() => _orden = orden);
    _cargar();
  }

  Future<void> _abrirDetalle(Product producto) async {
    final resultado = await Navigator.pushNamed<ProductoResultado>(
      context,
      RouterApk.productoDetalle,
      arguments: producto.id,
    );
    if (resultado == null || !mounted) return;
    setState(() {
      if (resultado.eliminado) {
        _productos.removeWhere((p) => p.id == producto.id);
        _total = _total > 0 ? _total - 1 : 0;
      } else if (resultado.producto != null) {
        final i = _productos.indexWhere((p) => p.id == producto.id);
        if (i != -1) _productos[i] = resultado.producto!;
      }
    });
  }

  Future<void> _crear() async {
    final creado = await Navigator.pushNamed<Product>(context, RouterApk.productoForm);
    if (creado == null || !mounted) return;
    setState(() {
      _productos.insert(0, creado);
      _total += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Productos"),
        actions: [
          PopupMenuButton<_Orden>(
            icon: const Icon(Icons.sort),
            tooltip: "Ordenar",
            onSelected: _elegirOrden,
            itemBuilder: (_) => [
              for (final o in _ordenes)
                CheckedPopupMenuItem<_Orden>(
                  value: o,
                  checked: o == _orden,
                  child: Text(o.etiqueta),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _busqueda,
              onChanged: _alBuscar,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: "Buscar productos",
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _chip("Todas", _categoria == null, () => _elegirCategoria(null)),
                for (final c in _categorias)
                  _chip(c.name, _categoria == c.slug, () => _elegirCategoria(c.slug)),
              ],
            ),
          ),
          Expanded(child: _contenido()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'agregar_producto',
        onPressed: _crear,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _chip(String texto, bool activo, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(texto),
        selected: activo,
        showCheckmark: false,
        selectedColor: Colors.black,
        labelStyle: TextStyle(color: activo ? Colors.white : Colors.black),
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _contenido() {
    if (_cargando) return const CargandoVista();
    if (_error != null) return ErrorVista(mensaje: _error!, onReintentar: _cargar);
    if (_productos.isEmpty) {
      return const VaciaVista(mensaje: "No se encontraron productos", icono: Icons.search_off);
    }
    return RefreshIndicator(
      color: Colors.black,
      onRefresh: _cargar,
      child: GridView.builder(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _productos.length + (_cargandoMas ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _productos.length) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }
          final producto = _productos[index];
          return ProductoCard(producto: producto, onTap: () => _abrirDetalle(producto));
        },
      ),
    );
  }
}
