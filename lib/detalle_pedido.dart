class DetallePedido {
  final int? id;
  final int pedidoId;
  final int platoId;
  final int cantidad;
  final double precioUnitario;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DetallePedido({
    this.id,
    required this.pedidoId,
    required this.platoId,
    required this.cantidad,
    required this.precioUnitario,
    this.createdAt,
    this.updatedAt,
  });

  factory DetallePedido.fromJson(Map<String, dynamic> json) => DetallePedido(
        id: json['id'],
        pedidoId: json['pedidoId'],
        platoId: json['platoId'],
        cantidad: json['cantidad'],
        precioUnitario: (json['precioUnitario'] as num).toDouble(),
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'pedidoId': pedidoId,
        'platoId': platoId,
        'cantidad': cantidad,
        'precioUnitario': precioUnitario,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };
}
