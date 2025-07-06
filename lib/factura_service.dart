import 'dart:convert';
import 'package:http/http.dart' as http;
import 'factura.dart';

class FacturaService {
  Future<Factura> updateFactura(Factura factura) async {
    if (factura.id == null) throw Exception('Factura sin ID');
    final res = await http.put(
      Uri.parse('$_baseUrl/${factura.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Android 14; Mobile) Flutter',
      },
      body: jsonEncode(factura.toJson()),
    );
    if (res.statusCode == 200) {
      return Factura.fromJson(jsonDecode(res.body));
    }
    throw Exception('Error ${res.statusCode}');
  }
  static const _baseUrl = 'http://localhost:3000/api/facturas';

  Future<List<Factura>> fetchFacturas() async {
    final res = await http.get(Uri.parse(_baseUrl), headers: {
      'Accept': 'application/json',
      'User-Agent': 'Mozilla/5.0 (Android 14; Mobile) Flutter',
    });
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Factura.fromJson(e)).toList();
    }
    throw Exception('Error ${res.statusCode}');
  }

  Future<Factura> createFactura(Factura factura) async {
    final res = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Android 14; Mobile) Flutter',
      },
      body: jsonEncode(factura.toJson()),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return Factura.fromJson(jsonDecode(res.body));
    }
    throw Exception('Error ${res.statusCode}');
  }

  Future<void> deleteFactura(int id) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Android 14; Mobile) Flutter',
      },
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Error ${res.statusCode}');
    }
  }
}
