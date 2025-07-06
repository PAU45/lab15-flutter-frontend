class Reserva {
  final int? id;
  final int mesaId;
  final int usuarioId;
  final String nombreCliente;
  final DateTime fecha;
  final int cantidadPersonas;

  Reserva({
    this.id,
    required this.mesaId,
    required this.usuarioId,
    required this.nombreCliente,
    required this.fecha,
    required this.cantidadPersonas,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) => Reserva(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
        mesaId: json['mesaId'] is int ? json['mesaId'] : int.tryParse(json['mesaId']?.toString() ?? '') ?? 0,
        usuarioId: json['usuarioId'] is int ? json['usuarioId'] : int.tryParse(json['usuarioId']?.toString() ?? '') ?? 0,
        nombreCliente: json['nombreCliente'] ?? '',
        fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : DateTime.now(),
        cantidadPersonas: json['cantidadPersonas'] is int ? json['cantidadPersonas'] : int.tryParse(json['cantidadPersonas']?.toString() ?? '') ?? 1,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'mesaId': mesaId,
        'usuarioId': usuarioId,
        'nombreCliente': nombreCliente,
        'fecha': fecha.toIso8601String(),
        'cantidadPersonas': cantidadPersonas,
      };
}
