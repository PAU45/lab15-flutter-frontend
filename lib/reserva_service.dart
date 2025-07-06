import 'dart:convert';
import 'package:http/http.dart' as http;
import 'reserva.dart';

class ReservaService {
  static const _baseUrl = 'http://localhost:3000/api/reservas';

  Future<List<Reserva>> fetchReservas() async {
    final res = await http.get(Uri.parse(_baseUrl), headers: {
      'Accept': 'application/json',
      'User-Agent': 'Mozilla/5.0 (Android 14; Mobile) Flutter',
    });
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Reserva.fromJson(e)).toList();
    }
    throw Exception('Error ${res.statusCode}');
  }

  Future<Reserva> createReserva(Reserva reserva) async {
    final res = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Android 14; Mobile) Flutter',
      },
      body: jsonEncode(reserva.toJson()),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return Reserva.fromJson(jsonDecode(res.body));
    }
    throw Exception('Error ${res.statusCode}');
  }

  Future<Reserva> updateReserva(Reserva reserva) async {
    if (reserva.id == null) throw Exception('Reserva sin id');
    final res = await http.put(
      Uri.parse('$_baseUrl/${reserva.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Android 14; Mobile) Flutter',
      },
      body: jsonEncode(reserva.toJson()),
    );
    if (res.statusCode == 200) {
      return Reserva.fromJson(jsonDecode(res.body));
    }
    throw Exception('Error ${res.statusCode}');
  }

  Future<void> deleteReserva(int id) async {
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
