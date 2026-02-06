import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas (ej: 20/10/2025)
import '../models/pedido.dart';
import '../models/cliente.dart';
import '../models/producto.dart';
import '../services/firestore_service.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // Variables para el formulario
  String? _clienteIdSeleccionado;
  String? _productoIdSeleccionado;
  String _estadoSeleccionado = 'Pendiente';
  DateTime _fechaSeleccionada = DateTime.now();

  // Método para mostrar el formulario
  void _mostrarFormulario({Pedido? pedido}) {
    // 1. Preparar datos
    if (pedido != null) {
      _clienteIdSeleccionado = pedido.clienteId;
      _productoIdSeleccionado = pedido.productoId;
      _estadoSeleccionado = pedido.estado;
      _fechaSeleccionada = pedido.fecha;
    } else {
      _clienteIdSeleccionado = null;
      _productoIdSeleccionado = null;
      _estadoSeleccionado = 'Pendiente';
      _fechaSeleccionada = DateTime.now();
    }

    showDialog(
      context: context,
      builder: (context) {
        // 2. Cargar Clientes (Primer Stream)
        return StreamBuilder<List<Cliente>>(
          stream: _firestoreService.getClientes(),
          builder: (context, snapshotClientes) {
            if (!snapshotClientes.hasData) return const Center(child: CircularProgressIndicator());
            final clientes = snapshotClientes.data!;

            // 3. Cargar Productos (Segundo Stream anidado)
            return StreamBuilder<List<Producto>>(
              stream: _firestoreService.getProductos(),
              builder: (context, snapshotProductos) {
                if (!snapshotProductos.hasData) return const Center(child: CircularProgressIndicator());
                final productos = snapshotProductos.data!;

                // 4. Mostrar el Diálogo con los datos listos
                return StatefulBuilder(
                  builder: (context, setStateDialog) {
                    return AlertDialog(
                      title: Text(pedido == null ? 'Nuevo Pedido' : 'Editar Pedido'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // SELECTOR CLIENTE
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _clienteIdSeleccionado,
                              hint: const Text('Selecciona Cliente'),
                              items: clientes.map((cli) {
                                return DropdownMenuItem(
                                  value: cli.id,
                                  child: Text(cli.nombre, overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (val) => setStateDialog(() => _clienteIdSeleccionado = val),
                              decoration: const InputDecoration(labelText: 'Cliente', border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 10),

                            // SELECTOR PRODUCTO
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _productoIdSeleccionado,
                              hint: const Text('Selecciona Producto'),
                              items: productos.map((prod) {
                                return DropdownMenuItem(
                                  value: prod.id,
                                  child: Text('${prod.nombre} (${prod.precio}€)', overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (val) => setStateDialog(() => _productoIdSeleccionado = val),
                              decoration: const InputDecoration(labelText: 'Producto', border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 10),

                            // SELECTOR FECHA
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Fecha: ${DateFormat('dd/MM/yyyy').format(_fechaSeleccionada)}'),
                                TextButton(
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _fechaSeleccionada,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                    );
                                    if (picked != null) {
                                      setStateDialog(() => _fechaSeleccionada = picked);
                                    }
                                  },
                                  child: const Text('Cambiar', style: TextStyle(color: Color(0xFF01488e))),
                                )
                              ],
                            ),
                            const SizedBox(height: 10),

                            // SELECTOR ESTADO
                            DropdownButtonFormField<String>(
                              value: _estadoSeleccionado,
                              items: ['Pendiente', 'En Proceso', 'Entregado']
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (val) => setStateDialog(() => _estadoSeleccionado = val!),
                              decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF01488e)),
                          onPressed: () async {
                            if (_clienteIdSeleccionado == null || _productoIdSeleccionado == null) {
                              return; // Validación básica
                            }

                            final nuevoPedido = Pedido(
                              id: pedido?.id,
                              clienteId: _clienteIdSeleccionado!,
                              productoId: _productoIdSeleccionado!,
                              fecha: _fechaSeleccionada,
                              estado: _estadoSeleccionado,
                            );

                            if (pedido == null) {
                              await _firestoreService.addPedido(nuevoPedido);
                            } else {
                              await _firestoreService.updatePedido(nuevoPedido);
                            }

                            if (context.mounted) Navigator.pop(context);
                          },
                          child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  // Pequeño helper para el color del estado
  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'Pendiente': return Colors.orange;
      case 'En Proceso': return Colors.blue;
      case 'Entregado': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        backgroundColor: const Color(0xFF01488e),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF01488e),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _mostrarFormulario(),
      ),
      body: StreamBuilder<List<Pedido>>(
        stream: _firestoreService.getPedidos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final pedidos = snapshot.data!;

          if (pedidos.isEmpty) return const Center(child: Text('No hay pedidos registrados.'));

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final ped = pedidos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColorEstado(ped.estado),
                    child: const Icon(Icons.assignment, color: Colors.white),
                  ),
                  title: Text(
                    'Pedido ${DateFormat('dd/MM').format(ped.fecha)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // Nota académica: Aquí mostramos los IDs para simplificar código.
                  // En una app real haríamos otra consulta para sacar el nombre.
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ped.estado, style: TextStyle(color: _getColorEstado(ped.estado), fontWeight: FontWeight.bold)),
                      Text('Cliente ID: ...${ped.clienteId.substring(ped.clienteId.length > 4 ? ped.clienteId.length - 4 : 0)}', style: const TextStyle(fontSize: 10)),
                      Text('Prod ID: ...${ped.productoId.substring(ped.productoId.length > 4 ? ped.productoId.length - 4 : 0)}', style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _mostrarFormulario(pedido: ped),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _firestoreService.deletePedido(ped.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}