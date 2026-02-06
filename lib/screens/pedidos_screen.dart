import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import '../models/pedido.dart';
import '../models/cliente.dart';
import '../models/producto.dart';
import '../services/firestore_service.dart';
import '../widgets/input_decorations.dart';

class PedidosScreen extends StatefulWidget {
  @override
  _PedidosScreenState createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // Variables para el formulario
  String? _clienteIdSeleccionado;
  String? _productoIdSeleccionado;
  String _estadoSeleccionado = 'Pendiente';
  DateTime _fechaSeleccionada = DateTime.now();

  // Método para mostrar el formulario (El más complejo de la app)
  void _mostrarFormulario({Pedido? pedido}) {
    // Si editamos, cargamos los datos existentes
    if (pedido != null) {
      _clienteIdSeleccionado = pedido.clienteId;
      _productoIdSeleccionado = pedido.productoId;
      _estadoSeleccionado = pedido.estado;
      _fechaSeleccionada = pedido.fecha;
    } else {
      // Si es nuevo, reseteamos
      _clienteIdSeleccionado = null;
      _productoIdSeleccionado = null;
      _estadoSeleccionado = 'Pendiente';
      _fechaSeleccionada = DateTime.now();
    }

    showDialog(
      context: context,
      builder: (context) {
        // Necesitamos cargar Clientes y Productos para llenar los Dropdowns.
        // Usamos StreamBuilder anidados. Es la forma más fácil de explicar:
        // "Primero cargo clientes, luego cargo productos, luego pinto el formulario".
        
        return StreamBuilder<List<Cliente>>(
          stream: _firestoreService.getClientes(),
          builder: (context, snapshotClientes) {
            if (!snapshotClientes.hasData) return Center(child: CircularProgressIndicator());
            final clientes = snapshotClientes.data!;

            return StreamBuilder<List<Producto>>(
              stream: _firestoreService.getProductos(),
              builder: (context, snapshotProductos) {
                if (!snapshotProductos.hasData) return Center(child: CircularProgressIndicator());
                final productos = snapshotProductos.data!;

                return StatefulBuilder(
                  builder: (context, setStateDialog) {
                    return AlertDialog(
                      title: Text(pedido == null ? 'Nuevo Pedido' : 'Editar Pedido'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 1. Selector de Cliente
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _clienteIdSeleccionado,
                              hint: Text('Selecciona Cliente'),
                              items: clientes.map((cli) {
                                return DropdownMenuItem(
                                  value: cli.id,
                                  child: Text(cli.nombre, overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (val) => setStateDialog(() => _clienteIdSeleccionado = val),
                              decoration: InputDecorations.authInputDecoration(
                                  hintText: '', labelText: 'Cliente'),
                            ),
                            SizedBox(height: 10),

                            // 2. Selector de Producto
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _productoIdSeleccionado,
                              hint: Text('Selecciona Producto'),
                              items: productos.map((prod) {
                                return DropdownMenuItem(
                                  value: prod.id,
                                  child: Text('${prod.nombre} (${prod.precio}€)', 
                                      overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (val) => setStateDialog(() => _productoIdSeleccionado = val),
                              decoration: InputDecorations.authInputDecoration(
                                  hintText: '', labelText: 'Producto'),
                            ),
                            SizedBox(height: 10),

                            // 3. Selector de Fecha
                            Row(
                              children: [
                                Text('Fecha: ${DateFormat('dd/MM/yyyy').format(_fechaSeleccionada)}'),
                                Spacer(),
                                TextButton(
                                  child: Text('Cambiar', style: TextStyle(color: Color(0xFF01488e))),
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _fechaSeleccionada,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                      // Color personalizado para el calendario
                                      builder: (context, child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            colorScheme: ColorScheme.light(primary: Color(0xFF01488e)),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      setStateDialog(() => _fechaSeleccionada = picked);
                                    }
                                  },
                                )
                              ],
                            ),
                            SizedBox(height: 10),

                            // 4. Estado
                            DropdownButtonFormField<String>(
                              value: _estadoSeleccionado,
                              items: ['Pendiente', 'En Proceso', 'Entregado']
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (val) => setStateDialog(() => _estadoSeleccionado = val!),
                              decoration: InputDecorations.authInputDecoration(
                                  hintText: '', labelText: 'Estado'),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF01488e)),
                          onPressed: () async {
                            if (_clienteIdSeleccionado == null || _productoIdSeleccionado == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Debes seleccionar cliente y producto')),
                              );
                              return;
                            }

                            final nuevoPedido = Pedido(
                              id: pedido?.id, // Si es null, Firebase crea uno nuevo
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
                            Navigator.pop(context);
                          },
                          child: Text('Guardar'),
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

  // Helper para pintar el color del estado
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
        title: Text('Pedidos'),
        backgroundColor: Color(0xFF01488e),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF01488e),
        child: Icon(Icons.add),
        onPressed: () => _mostrarFormulario(),
      ),
      body: StreamBuilder<List<Pedido>>(
        stream: _firestoreService.getPedidos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error'));
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final pedidos = snapshot.data!;

          if (pedidos.isEmpty) return Center(child: Text('No hay pedidos registrados'));

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColorEstado(pedido.estado),
                    child: Icon(Icons.assignment, color: Colors.white),
                  ),
                  title: Text(
                    'Pedido ${DateFormat('dd/MM/yyyy').format(pedido.fecha)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // Nota académica: Aquí mostramos los IDs. En una app real haríamos 
                  // una consulta extra para sacar los nombres, pero para mantener 
                  // el código simple, mostramos los identificadores de la relación.
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estado: ${pedido.estado}', 
                          style: TextStyle(fontWeight: FontWeight.bold, color: _getColorEstado(pedido.estado))),
                      SizedBox(height: 4),
                      Text('ID Cliente: ...${pedido.clienteId.substring(pedido.clienteId.length > 5 ? pedido.clienteId.length - 5 : 0)}', 
                           style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text('ID Producto: ...${pedido.productoId.substring(pedido.productoId.length > 5 ? pedido.productoId.length - 5 : 0)}',
                           style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    onSelected: (value) async {
                      if (value == 'editar') {
                        _mostrarFormulario(pedido: pedido);
                      } else if (value == 'borrar') {
                        await _firestoreService.deletePedido(pedido.id!);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'editar', child: Text('Editar')),
                      PopupMenuItem(value: 'borrar', child: Text('Borrar', style: TextStyle(color: Colors.red))),
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