import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pedido.dart';

class PedidoService {
  static const _baseUrl = 'http://localhost:3000/api/pedidos';

  Future<List<Pedido>> fetchPedidos() async {
    final res = await http.get(Uri.parse(_baseUrl), headers: {
      'Accept': 'application/json',
      'User-Agent': 'Mozilla/5.0 (Android 14; Mobile) Flutter',
    });
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Pedido.fromJson(e)).toList();
    }
    throw Exception('Error ${res.statusCode}');
  }

  Future<Pedido> createPedido(Pedido pedido) async {
    final res = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Android 14; Mobile) Flutter',
      },
      body: jsonEncode(pedido.toJson()),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return Pedido.fromJson(jsonDecode(res.body));
    }
    throw Exception('Error ${res.statusCode}');
  }

  Future<Pedido> updatePedido(Pedido pedido) async {
    if (pedido.id == null) throw Exception('Pedido sin id');
    final res = await http.put(
      Uri.parse('$_baseUrl/${pedido.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Android 14; Mobile) Flutter',
      },
      body: jsonEncode(pedido.toJson()),
    );
    if (res.statusCode == 200) {
      return Pedido.fromJson(jsonDecode(res.body));
    }
    throw Exception('Error ${res.statusCode}');
  }

  Future<void> deletePedido(int id) async {
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
