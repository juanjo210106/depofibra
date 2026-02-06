class Producto {
  String? id; // El ID del documento en Firebase
  String nombre;
  String tipo; // 'deposito' o 'piscina'
  double capacidad;
  double precio;

  Producto({
    this.id,
    required this.nombre,
    required this.tipo,
    required this.capacidad,
    required this.precio,
  });

  // Convierte el objeto a un Mapa para guardarlo en Firebase
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'tipo': tipo,
      'capacidad': capacidad,
      'precio': precio,
    };
  }

  // Crea el objeto desde los datos que nos da Firebase
  factory Producto.fromMap(Map<String, dynamic> map, String id) {
    return Producto(
      id: id,
      nombre: map['nombre'] ?? '',
      tipo: map['tipo'] ?? 'deposito',
      // Convertimos a double para asegurar que no falle si viene un entero
      capacidad: (map['capacidad'] ?? 0).toDouble(),
      precio: (map['precio'] ?? 0).toDouble(),
    );
  }
}