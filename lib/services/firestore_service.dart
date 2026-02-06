import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/producto.dart';
import '../models/cliente.dart';
import '../models/pedido.dart';

class FirestoreService {
  // Instancia principal de Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================================
  // SECCIÓN: PRODUCTOS
  // ==========================================

  // LEER: Obtener lista de productos en tiempo real (Stream)
  Stream<List<Producto>> getProductos() {
    return _db.collection('productos').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Producto.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // ESCRIBIR: Añadir un nuevo producto
  Future<void> addProducto(Producto producto) {
    return _db.collection('productos').add(producto.toMap());
  }

  // EDITAR: Actualizar un producto existente
  Future<void> updateProducto(Producto producto) {
    return _db
        .collection('productos')
        .doc(producto.id)
        .update(producto.toMap());
  }

  // BORRAR: Eliminar un producto
  Future<void> deleteProducto(String id) {
    return _db.collection('productos').doc(id).delete();
  }

  // ==========================================
  // SECCIÓN: CLIENTES
  // ==========================================

  Stream<List<Cliente>> getClientes() {
    return _db.collection('clientes').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Cliente.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addCliente(Cliente cliente) {
    return _db.collection('clientes').add(cliente.toMap());
  }

  Future<void> updateCliente(Cliente cliente) {
    return _db.collection('clientes').doc(cliente.id).update(cliente.toMap());
  }

  Future<void> deleteCliente(String id) {
    return _db.collection('clientes').doc(id).delete();
  }

  // ==========================================
  // SECCIÓN: PEDIDOS (Con Filtrado y Ordenación)
  // ==========================================

  // Ejemplo de Ordenación: Pedidos ordenados por fecha (Más reciente primero)
  Stream<List<Pedido>> getPedidos() {
    return _db
        .collection('pedidos')
        .orderBy('fecha', descending: true) // <--- Ordenación (Para subir nota)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Pedido.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addPedido(Pedido pedido) {
    return _db.collection('pedidos').add(pedido.toMap());
  }

  Future<void> updatePedido(Pedido pedido) {
    return _db.collection('pedidos').doc(pedido.id).update(pedido.toMap());
  }

  Future<void> deletePedido(String id) {
    return _db.collection('pedidos').doc(id).delete();
  }
}