class Mesa {
  final int? id;
  final int numeroMesa;
  final int capacidad;
  final String estado;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Mesa({
    this.id,
    required this.numeroMesa,
    required this.capacidad,
    required this.estado,
    this.createdAt,
    this.updatedAt,
  });

  factory Mesa.fromJson(Map<String, dynamic> json) => Mesa(
        id: json['id'],
        numeroMesa: json['numeroMesa'],
        capacidad: json['capacidad'],
        estado: json['estado'] ?? '',
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'numeroMesa': numeroMesa,
        'capacidad': capacidad,
        'estado': estado,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };
}
