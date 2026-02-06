import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/producto.dart';
import '../models/cliente.dart';
import '../models/pedido.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================================
  // PRODUCTOS
  // ==========================================
  Stream<List<Producto>> getProductos() {
    return _db.collection('productos').snapshots().map((snap) {
      return snap.docs
          .map((doc) => Producto.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addProducto(Producto producto) async {
    await _db.collection('productos').add(producto.toMap());
  }

  Future<void> updateProducto(Producto producto) async {
    await _db.collection('productos').doc(producto.id).update(producto.toMap());
  }

  Future<void> deleteProducto(String id) async {
    await _db.collection('productos').doc(id).delete();
  }

  // ==========================================
  // CLIENTES
  // ==========================================
  Stream<List<Cliente>> getClientes() {
    return _db.collection('clientes').snapshots().map((snap) {
      return snap.docs
          .map((doc) => Cliente.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addCliente(Cliente cliente) async {
    await _db.collection('clientes').add(cliente.toMap());
  }

  Future<void> updateCliente(Cliente cliente) async {
    await _db.collection('clientes').doc(cliente.id).update(cliente.toMap());
  }

  Future<void> deleteCliente(String id) async {
    await _db.collection('clientes').doc(id).delete();
  }

  // ==========================================
  // PEDIDOS (Con ordenación por fecha)
  // ==========================================
  Stream<List<Pedido>> getPedidos() {
    return _db
        .collection('pedidos')
        .orderBy('fecha', descending: true) // Los más nuevos primero
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((doc) => Pedido.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addPedido(Pedido pedido) async {
    await _db.collection('pedidos').add(pedido.toMap());
  }

  Future<void> updatePedido(Pedido pedido) async {
    await _db.collection('pedidos').doc(pedido.id).update(pedido.toMap());
  }

  Future<void> deletePedido(String id) async {
    await _db.collection('pedidos').doc(id).delete();
  }
}