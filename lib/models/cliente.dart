class Cliente {
  String? id; // ID del documento en Firestore
  String nombre;
  String email;
  String telefono;

  Cliente({
    this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
  });

  // Convertir objeto a Mapa para subir a Firebase
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
    };
  }

  // Crear objeto desde un Mapa de Firebase
  factory Cliente.fromMap(Map<String, dynamic> map, String documentId) {
    return Cliente(
      id: documentId,
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
    );
  }
}