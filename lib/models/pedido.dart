import 'package:cloud_firestore/cloud_firestore.dart';

class Pedido {
  String? id;
  String clienteId;  // "Llave foránea" que apunta a la colección clientes
  String productoId; // "Llave foránea" que apunta a la colección productos
  DateTime fecha;
  String estado;     // Ejemplo: "Pendiente", "En proceso", "Entregado"

  Pedido({
    this.id,
    required this.clienteId,
    required this.productoId,
    required this.fecha,
    required this.estado,
  });

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'productoId': productoId,
      // Firebase prefiere recibir Timestamp, pero suele aceptar DateTime.
      // Para ser estrictos y evitar errores, lo convertimos:
      'fecha': Timestamp.fromDate(fecha),
      'estado': estado,
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map, String documentId) {
    return Pedido(
      id: documentId,
      clienteId: map['clienteId'] ?? '',
      productoId: map['productoId'] ?? '',
      // IMPORTANTE: Firebase devuelve un objeto 'Timestamp', no un DateTime directo.
      // Debemos convertirlo con .toDate()
      fecha: (map['fecha'] as Timestamp).toDate(),
      estado: map['estado'] ?? 'Pendiente',
    );
  }
}