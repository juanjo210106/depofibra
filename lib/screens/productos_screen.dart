import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/firestore_service.dart';
import '../widgets/input_decorations.dart';

class ProductosScreen extends StatefulWidget {
  @override
  _ProductosScreenState createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // Controladores de texto para capturar lo que el usuario escribe
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _capacidadController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  
  // Variable para guardar la selección del desplegable
  String _tipoSeleccionado = 'deposito'; 

  // Esta función muestra el formulario flotante
  void _mostrarFormulario({Producto? producto}) {
    // Si pasamos un producto, es MODO EDICIÓN: rellenamos los campos
    if (producto != null) {
      _nombreController.text = producto.nombre;
      _capacidadController.text = producto.capacidad.toString();
      _precioController.text = producto.precio.toString();
      _tipoSeleccionado = producto.tipo;
    } else {
      // Si no, es MODO CREAR: limpiamos los campos
      _nombreController.clear();
      _capacidadController.clear();
      _precioController.clear();
      _tipoSeleccionado = 'deposito';
    }

    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder es necesario para que el Dropdown cambie visualmente DENTRO del diálogo
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(producto == null ? 'Nuevo Producto' : 'Editar Producto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // El diálogo se ajusta al contenido
                  children: [
                    TextField(
                      controller: _nombreController,
                      decoration: InputDecorations.authInputDecoration(
                          hintText: 'Ej. Depósito 2000L', labelText: 'Nombre'),
                    ),
                    SizedBox(height: 10),
                    // Desplegable para Tipo
                    DropdownButtonFormField<String>(
                      value: _tipoSeleccionado,
                      items: ['deposito', 'piscina'].map((tipo) {
                        return DropdownMenuItem(
                          value: tipo,
                          child: Text(tipo.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        // Usamos setStateDialog para redibujar solo el diálogo
                        setStateDialog(() => _tipoSeleccionado = val!);
                      },
                      decoration: InputDecorations.authInputDecoration(
                          hintText: 'Tipo', labelText: 'Tipo'),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _capacidadController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecorations.authInputDecoration(
                          hintText: 'Litros', labelText: 'Capacidad'),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _precioController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecorations.authInputDecoration(
                          hintText: 'Euros', labelText: 'Precio'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), // Cerrar sin guardar
                  child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF01488e)),
                  onPressed: () async {
                    // 1. Recoger datos
                    final nombre = _nombreController.text;
                    // tryParse evita errores si el usuario escribe texto en vez de números
                    final capacidad = double.tryParse(_capacidadController.text) ?? 0;
                    final precio = double.tryParse(_precioController.text) ?? 0;

                    if (nombre.isEmpty) return; // Validación simple

                    // 2. Guardar en Firebase
                    if (producto == null) {
                      // CREAR NUEVO
                      await _firestoreService.addProducto(Producto(
                        nombre: nombre,
                        tipo: _tipoSeleccionado,
                        capacidad: capacidad,
                        precio: precio,
                      ));
                    } else {
                      // ACTUALIZAR EXISTENTE (Usamos el ID original)
                      await _firestoreService.updateProducto(Producto(
                        id: producto.id,
                        nombre: nombre,
                        tipo: _tipoSeleccionado,
                        capacidad: capacidad,
                        precio: precio,
                      ));
                    }

                    Navigator.pop(context); // Cerrar diálogo tras guardar
                  },
                  child: Text('Guardar'),
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
        title: Text('Productos'),
        backgroundColor: Color(0xFF01488e),
      ),
      // Botón flotante para añadir
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF01488e),
        child: Icon(Icons.add),
        onPressed: () => _mostrarFormulario(),
      ),
      // StreamBuilder escucha los cambios en la base de datos en vivo
      body: StreamBuilder<List<Producto>>(
        stream: _firestoreService.getProductos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error al cargar datos'));
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final productos = snapshot.data!;

          if (productos.isEmpty) {
            return Center(child: Text('No hay productos registrados'));
          }

          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final prod = productos[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: prod.tipo == 'piscina' 
                        ? Colors.blue[100] 
                        : Colors.grey[200],
                    child: Icon(
                      prod.tipo == 'piscina' ? Icons.pool : Icons.water_damage,
                      color: Color(0xFF01488e),
                    ),
                  ),
                  title: Text(prod.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${prod.capacidad.toStringAsFixed(0)} L  |  ${prod.precio} €'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón Editar
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.indigo),
                        onPressed: () => _mostrarFormulario(producto: prod),
                      ),
                      // Botón Borrar
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red[300]),
                        onPressed: () async {
                          // Preguntar confirmación (Opcional, pero buena práctica)
                          await _firestoreService.deleteProducto(prod.id!);
                        },
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