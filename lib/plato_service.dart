
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'plato.dart';



class PlatoService {
  Future<void> deletePlato(int id) async {
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
  static const String _baseUrl = 'http://localhost:3000/api/platos';

  Future<List<Plato>> fetchPlatos() async {
    final res = await http.get(Uri.parse(_baseUrl), headers: {
      'Accept': 'application/json',
      'User-Agent': 'Mozilla/5.0 (Android 14; Mobile) Flutter',
    });
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Plato.fromJson(e)).toList();
    }
    throw Exception('Error ${res.statusCode}');
  }

  Future<Plato> createPlato(Plato plato) async {
    final res = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Android 14; Mobile) Flutter',
      },
      body: jsonEncode(plato.toJson()),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return Plato.fromJson(jsonDecode(res.body));
    }
    throw Exception('Error ${res.statusCode}');
  }

  Future<Plato> updatePlato(Plato plato) async {
    if (plato.id == null) throw Exception('ID requerido para actualizar');
    final res = await http.put(
      Uri.parse('$_baseUrl/${plato.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Android 14; Mobile) Flutter',
      },
      body: jsonEncode(plato.toJson()),
    );
    if (res.statusCode == 200) {
      return Plato.fromJson(jsonDecode(res.body));
    }
    throw Exception('Error ${res.statusCode}');
  }
}
