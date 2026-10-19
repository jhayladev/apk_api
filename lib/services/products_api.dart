import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/models.dart';

class ProductsApi {
  static const Map<String, String> _json = {"Content-Type": "application/json"};

  static Uri _uri(String ruta, [Map<String, String>? query]) {
    return Uri.parse("${ApiConfig.productosBase}$ruta").replace(queryParameters: query);
  }

  static Future<ProductsPage> obtenerProductos({
    int limit = 20,
    int skip = 0,
    String? busqueda,
    String? categoria,
    String? ordenarPor,
    String orden = "asc",
  }) async {
    final query = <String, String>{"limit": "$limit", "skip": "$skip"};
    if (ordenarPor != null) {
      query["sortBy"] = ordenarPor;
      query["order"] = orden;
    }
    String ruta = "/products";
    if (busqueda != null && busqueda.trim().isNotEmpty) {
      ruta = "/products/search";
      query["q"] = busqueda.trim();
    } else if (categoria != null && categoria.isNotEmpty) {
      ruta = "/products/category/$categoria";
    }
    final respuesta = await http.get(_uri(ruta, query)).timeout(ApiConfig.tiempoEspera);
    if (respuesta.statusCode != 200) {
      throw Exception("No se pudieron cargar los productos (${respuesta.statusCode})");
    }
    return ProductsPage.fromJson(jsonDecode(respuesta.body) as Map<String, dynamic>);
  }

  static Future<Product> obtenerProducto(int id) async {
    final respuesta = await http.get(_uri("/products/$id")).timeout(ApiConfig.tiempoEspera);
    if (respuesta.statusCode != 200) {
      throw Exception("No se pudo cargar el producto (${respuesta.statusCode})");
    }
    return Product.fromJson(jsonDecode(respuesta.body) as Map<String, dynamic>);
  }

  static Future<List<ProductCategory>> obtenerCategorias() async {
    final respuesta = await http.get(_uri("/products/categories")).timeout(ApiConfig.tiempoEspera);
    if (respuesta.statusCode != 200) {
      throw Exception("No se pudieron cargar las categorías (${respuesta.statusCode})");
    }
    final data = jsonDecode(respuesta.body) as List;
    return data.map((e) => ProductCategory.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Product?> crearProducto(Product producto) async {
    final respuesta = await http
        .post(_uri("/products/add"), headers: _json, body: jsonEncode(producto.paraEnvio()))
        .timeout(ApiConfig.tiempoEspera);
    if (respuesta.statusCode != 200 && respuesta.statusCode != 201) return null;
    final data = jsonDecode(respuesta.body) as Map<String, dynamic>;
    return Product.fromJson({...producto.toJson(), ...data});
  }

  static Future<Product?> editarProducto(Product producto) async {
    final respuesta = await http
        .patch(_uri("/products/${producto.id}"), headers: _json, body: jsonEncode(producto.paraEnvio()))
        .timeout(ApiConfig.tiempoEspera);
    if (respuesta.statusCode != 200) return null;
    final data = jsonDecode(respuesta.body) as Map<String, dynamic>;
    return Product.fromJson({...producto.toJson(), ...data});
  }

  static Future<bool> eliminarProducto(int id) async {
    final respuesta = await http.delete(_uri("/products/$id")).timeout(ApiConfig.tiempoEspera);
    return respuesta.statusCode == 200;
  }
}
