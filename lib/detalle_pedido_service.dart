import 'dart:convert';
import 'package:http/http.dart' as http;
import 'detalle_pedido.dart';

class DetallePedidoService {
  static const _baseUrl = 'http://localhost:3000/api/detallepedidos';

  Future<List<DetallePedido>> fetchDetalles() async {
    final res = await http.get(Uri.parse(_baseUrl), headers: {
      'Accept': 'application/json',
      'User-Agent': 'Mozilla/5.0 (Android 14; Mobile) Flutter',
    });
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => DetallePedido.fromJson(e)).toList();
    }
    throw Exception('Error ${res.statusCode}');
  }

  Future<DetallePedido> createDetalle(DetallePedido detalle) async {
    final res = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Android 14; Mobile) Flutter',
      },
      body: jsonEncode(detalle.toJson()),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return DetallePedido.fromJson(jsonDecode(res.body));
    }
    throw Exception('Error ${res.statusCode}');
  }

  Future<void> deleteDetalle(int id) async {
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
