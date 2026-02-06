import 'package:cloud_firestore/cloud_firestore.dart';

class Pedido {
  String? id;
  String clienteId;
  String productoId;
  DateTime fecha;
  String estado; // 'Pendiente', 'Entregado', etc.

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
      // Firebase necesita Timestamp, no DateTime
      'fecha': Timestamp.fromDate(fecha),
      'estado': estado,
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map, String id) {
    return Pedido(
      id: id,
      clienteId: map['clienteId'] ?? '',
      productoId: map['productoId'] ?? '',
      // Convertimos el Timestamp de Firebase a DateTime de Dart
      fecha: (map['fecha'] as Timestamp).toDate(),
      estado: map['estado'] ?? 'Pendiente',
    );
  }
}