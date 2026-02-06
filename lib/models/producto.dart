class Producto {
  String? id; // El ID único del documento en Firestore
  String nombre;
  String tipo; // 'deposito' o 'piscina'
  double capacidad; // Lo guardaremos como número para poder ordenar por tamaño
  double precio;

  Producto({
    this.id,
    required this.nombre,
    required this.tipo,
    required this.capacidad,
    required this.precio,
  });

  // Método para convertir nuestro objeto a un Mapa (JSON)
  // Esto es necesario para subir los datos a Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'tipo': tipo,
      'capacidad': capacidad,
      'precio': precio,
    };
  }

  // Método de fábrica para crear un Producto desde un Mapa de Firestore
  // Esto se usa cuando descargamos datos de la base de datos
  factory Producto.fromMap(Map<String, dynamic> map, String documentId) {
    return Producto(
      id: documentId, // Guardamos el ID del documento para poder editarlo o borrarlo después
      nombre: map['nombre'] ?? '',
      tipo: map['tipo'] ?? 'deposito',
      // Convertimos a double explícitamente para evitar errores si Firestore devuelve un int
      capacidad: (map['capacidad'] ?? 0).toDouble(),
      precio: (map['precio'] ?? 0).toDouble(),
    );
  }
}