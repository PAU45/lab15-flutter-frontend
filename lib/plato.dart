class Plato {
  final int? id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String categoria;
  final String? urlImagen;

  Plato({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    this.urlImagen,
  });

  factory Plato.fromJson(Map<String, dynamic> json) => Plato(
        id: json['id'],
        nombre: json['nombre'],
        descripcion: json['descripcion'],
        precio: _parsePrecio(json['precio']),
        categoria: json['categoria'],
        urlImagen: json['urlImagen'],
      );

  static double _parsePrecio(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'categoria': categoria,
        'urlImagen': urlImagen,
      };
// ...existing code...
}
