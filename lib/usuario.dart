class Usuario {
  final int? id;
  final String nombre;
  final String email;
  final String password;
  final String rol;

  Usuario({
    this.id,
    required this.nombre,
    required this.email,
    required this.password,
    required this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'],
        nombre: json['nombre'],
        email: json['email'],
        password: json['password'] ?? '',
        rol: json['rol'] ?? 'mesero',
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'nombre': nombre,
        'email': email,
        'password': password,
        'rol': rol,
      };
}
