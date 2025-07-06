class Factura {
  final int? id;
  final int pedidoId;
  final DateTime fecha;
  final double total;
  final String metodoPago;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Factura({
    this.id,
    required this.pedidoId,
    required this.fecha,
    required this.total,
    required this.metodoPago,
    this.createdAt,
    this.updatedAt,
  });

  factory Factura.fromJson(Map<String, dynamic> json) => Factura(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
        pedidoId: json['pedidoId'] is int ? json['pedidoId'] : int.tryParse(json['pedidoId'].toString()) ?? 0,
        fecha: DateTime.parse(json['fecha']),
        total: _parseTotal(json['total']),
        metodoPago: json['metodoPago'],
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      );

  static double _parseTotal(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'pedidoId': pedidoId,
        'fecha': fecha.toIso8601String(),
        'total': total,
        'metodoPago': metodoPago,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };
}
