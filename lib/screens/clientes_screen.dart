import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../services/firestore_service.dart';
import '../widgets/input_decorations.dart';

class ClientesScreen extends StatefulWidget {
  @override
  _ClientesScreenState createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // Controladores para los campos de texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  // Método para mostrar el formulario de crear/editar
  void _mostrarFormulario({Cliente? cliente}) {
    if (cliente != null) {
      // Editar: rellenamos datos
      _nombreController.text = cliente.nombre;
      _emailController.text = cliente.email;
      _telefonoController.text = cliente.telefono;
    } else {
      // Crear: limpiamos datos
      _nombreController.clear();
      _emailController.clear();
      _telefonoController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(cliente == null ? 'Nuevo Cliente' : 'Editar Cliente'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nombreController,
                  decoration: InputDecorations.authInputDecoration(
                      hintText: 'Nombre del cliente', labelText: 'Nombre'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecorations.authInputDecoration(
                      hintText: 'cliente@email.com', labelText: 'Email'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecorations.authInputDecoration(
                      hintText: '+34 600 000 000', labelText: 'Teléfono'),
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
                final nombre = _nombreController.text;
                final email = _emailController.text;
                final telefono = _telefonoController.text;

                if (nombre.isEmpty) return;

                if (cliente == null) {
                  // Guardar nuevo
                  await _firestoreService.addCliente(Cliente(
                    nombre: nombre,
                    email: email,
                    telefono: telefono,
                  ));
                } else {
                  // Actualizar existente
                  await _firestoreService.updateCliente(Cliente(
                    id: cliente.id,
                    nombre: nombre,
                    email: email,
                    telefono: telefono,
                  ));
                }

                Navigator.pop(context);
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clientes'),
        backgroundColor: Color(0xFF01488e),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF01488e),
        child: Icon(Icons.add),
        onPressed: () => _mostrarFormulario(),
      ),
      body: StreamBuilder<List<Cliente>>(
        stream: _firestoreService.getClientes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error'));
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final clientes = snapshot.data!;

          if (clientes.isEmpty) {
            return Center(child: Text('No hay clientes registrados'));
          }

          return ListView.builder(
            itemCount: clientes.length,
            itemBuilder: (context, index) {
              final cli = clientes[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFF01488e),
                    child: Text(
                      cli.nombre.isNotEmpty ? cli.nombre[0].toUpperCase() : '?',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(cli.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📧 ${cli.email}'),
                      Text('📞 ${cli.telefono}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.indigo),
                        onPressed: () => _mostrarFormulario(cliente: cli),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red[300]),
                        onPressed: () async {
                          await _firestoreService.deleteCliente(cli.id!);
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