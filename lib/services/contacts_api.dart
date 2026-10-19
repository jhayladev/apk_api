import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/models.dart';

class ContactsApi {
  static final Uri _url = Uri.parse("${ApiConfig.contactosBase}/contacts");
  static const Map<String, String> _json = {"Content-Type": "application/json"};

  static Uri _porId(int id) => Uri.parse("${ApiConfig.contactosBase}/contacts/$id");

  static Future<List<Contact>> obtenerContactos() async {
    final respuesta = await http.get(_url).timeout(ApiConfig.tiempoEspera);
    if (respuesta.statusCode != 200) {
      throw Exception("No se pudieron cargar los contactos (${respuesta.statusCode})");
    }
    final data = jsonDecode(respuesta.body) as List;
    return data.map((e) => Contact.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<bool> crearContacto(Contact contacto) async {
    final respuesta = await http
        .post(_url, headers: _json, body: jsonEncode(contacto.toJson()))
        .timeout(ApiConfig.tiempoEspera);
    return respuesta.statusCode == 201;
  }

  static Future<bool> editarContacto(Contact contacto) async {
    final respuesta = await http
        .put(_porId(contacto.id!), headers: _json, body: jsonEncode(contacto.toJson()))
        .timeout(ApiConfig.tiempoEspera);
    return respuesta.statusCode == 200;
  }

  static Future<bool> eliminarContacto(int id) async {
    final respuesta = await http.delete(_porId(id)).timeout(ApiConfig.tiempoEspera);
    return respuesta.statusCode == 200;
  }
}
