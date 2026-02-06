class Cliente {
  String? id;
  String nombre;
  String email;
  String telefono;

  Cliente({
    this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map, String id) {
    return Cliente(
      id: id,
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
    );
  }
}