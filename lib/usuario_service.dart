import 'dart:convert';
import 'package:http/http.dart' as http;
import 'usuario.dart';

class UsuarioService {
  static const _baseUrl = 'http://localhost:3000/api/usuarios';

  Future<List<Usuario>> fetchUsuarios() async {
    final res = await http.get(Uri.parse(_baseUrl), headers: {
      'Accept': 'application/json',
      'User-Agent': 'Mozilla/5.0 (Android 14; Mobile) Flutter',
    });
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Usuario.fromJson(e)).toList();
    }
    throw Exception('Error ${res.statusCode}');
  }

  Future<Usuario> createUsuario(Usuario usuario) async {
    final res = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Android 14; Mobile) Flutter',
      },
      body: jsonEncode(usuario.toJson()),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return Usuario.fromJson(jsonDecode(res.body));
    }
    throw Exception('Error ${res.statusCode}');
  }


  Future<Usuario> updateUsuario(Usuario usuario) async {
    if (usuario.id == null) throw Exception('Usuario sin id');
    final res = await http.put(
      Uri.parse('$_baseUrl/${usuario.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Android 14; Mobile) Flutter',
      },
      body: jsonEncode(usuario.toJson()),
    );
    if (res.statusCode == 200) {
      return Usuario.fromJson(jsonDecode(res.body));
    }
    throw Exception('Error ${res.statusCode}');
  }

  Future<void> deleteUsuario(int id) async {
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
