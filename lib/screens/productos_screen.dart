import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/firestore_service.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // Controladores de texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _capacidadController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  
  String _tipoSeleccionado = 'deposito'; // Valor por defecto

  // Función para mostrar el formulario (Crear o Editar)
  void _mostrarFormulario({Producto? producto}) {
    if (producto != null) {
      // Si editamos, rellenamos los datos
      _nombreController.text = producto.nombre;
      _capacidadController.text = producto.capacidad.toString();
      _precioController.text = producto.precio.toString();
      _tipoSeleccionado = producto.tipo;
    } else {
      // Si es nuevo, limpiamos
      _nombreController.clear();
      _capacidadController.clear();
      _precioController.clear();
      _tipoSeleccionado = 'deposito';
    }

    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder permite actualizar el Dropdown dentro del diálogo
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(producto == null ? 'Nuevo Producto' : 'Editar Producto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // CAMPO NOMBRE
                    TextField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        hintText: 'Ej. Depósito 2000L',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // CAMPO TIPO (Dropdown)
                    DropdownButtonFormField<String>(
                      value: _tipoSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Tipo',
                        border: OutlineInputBorder(),
                      ),
                      items: ['deposito', 'piscina'].map((tipo) {
                        return DropdownMenuItem(
                          value: tipo,
                          child: Text(tipo.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setStateDialog(() => _tipoSeleccionado = val!);
                      },
                    ),
                    const SizedBox(height: 10),

                    // CAMPO CAPACIDAD
                    TextField(
                      controller: _capacidadController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Capacidad (Litros)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // CAMPO PRECIO
                    TextField(
                      controller: _precioController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Precio (€)',
                        border: OutlineInputBorder(),
                      ),
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
                    // Guardar
                    final nombre = _nombreController.text;
                    final capacidad = double.tryParse(_capacidadController.text) ?? 0;
                    final precio = double.tryParse(_precioController.text) ?? 0;

                    if (nombre.isEmpty) return;

                    final nuevoProd = Producto(
                      id: producto?.id, // Mantiene ID si es edición
                      nombre: nombre,
                      tipo: _tipoSeleccionado,
                      capacidad: capacidad,
                      precio: precio,
                    );

                    if (producto == null) {
                      await _firestoreService.addProducto(nuevoProd);
                    } else {
                      await _firestoreService.updateProducto(nuevoProd);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        backgroundColor: const Color(0xFF01488e),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF01488e),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _mostrarFormulario(),
      ),
      // Lista en tiempo real
      body: StreamBuilder<List<Producto>>(
        stream: _firestoreService.getProductos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final productos = snapshot.data!;
          
          if (productos.isEmpty) {
            return const Center(child: Text('No hay productos registrados.'));
          }

          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final prod = productos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: prod.tipo == 'piscina' ? Colors.blue[100] : Colors.grey[300],
                    child: Icon(
                      prod.tipo == 'piscina' ? Icons.pool : Icons.water_damage,
                      color: const Color(0xFF01488e),
                    ),
                  ),
                  title: Text(prod.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${prod.capacidad.toStringAsFixed(0)} L  |  ${prod.precio} €'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _mostrarFormulario(producto: prod),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _firestoreService.deleteProducto(prod.id!),
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