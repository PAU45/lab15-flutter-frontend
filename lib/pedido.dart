class Pedido {
  final int? id;
  final int mesaId;
  final int usuarioId;
  final String estado;
  final double total;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Pedido({
    this.id,
    required this.mesaId,
    required this.usuarioId,
    required this.estado,
    required this.total,
    this.createdAt,
    this.updatedAt,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) => Pedido(
        id: json['id'] is int
            ? json['id']
            : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
        mesaId: json['mesaId'] is int
            ? json['mesaId']
            : (json['mesaId'] != null ? int.tryParse(json['mesaId'].toString()) ?? 0 : 0),
        usuarioId: json['usuarioId'] is int
            ? json['usuarioId']
            : (json['usuarioId'] != null ? int.tryParse(json['usuarioId'].toString()) ?? 0 : 0),
        estado: json['estado'] ?? '',
        total: json['total'] is String
            ? double.tryParse(json['total']) ?? 0
            : (json['total'] is num ? (json['total'] as num).toDouble() : 0),
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'mesaId': mesaId,
        'usuarioId': usuarioId,
        'estado': estado,
        'total': total,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };
}
