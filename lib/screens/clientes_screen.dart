import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../services/firestore_service.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // Controladores de texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  // Método para mostrar el formulario (Crear o Editar)
  void _mostrarFormulario({Cliente? cliente}) {
    if (cliente != null) {
      // Editar
      _nombreController.text = cliente.nombre;
      _emailController.text = cliente.email;
      _telefonoController.text = cliente.telefono;
    } else {
      // Crear
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
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Nombre del cliente',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'cliente@email.com',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    hintText: '+34 600 000 000',
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
                final nombre = _nombreController.text;
                final email = _emailController.text;
                final telefono = _telefonoController.text;

                if (nombre.isEmpty) return;

                final nuevoCliente = Cliente(
                  id: cliente?.id,
                  nombre: nombre,
                  email: email,
                  telefono: telefono,
                );

                if (cliente == null) {
                  await _firestoreService.addCliente(nuevoCliente);
                } else {
                  await _firestoreService.updateCliente(nuevoCliente);
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
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
        title: const Text('Clientes'),
        backgroundColor: const Color(0xFF01488e),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF01488e),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _mostrarFormulario(),
      ),
      body: StreamBuilder<List<Cliente>>(
        stream: _firestoreService.getClientes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final clientes = snapshot.data!;

          if (clientes.isEmpty) {
            return const Center(child: Text('No hay clientes registrados.'));
          }

          return ListView.builder(
            itemCount: clientes.length,
            itemBuilder: (context, index) {
              final cli = clientes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF01488e),
                    child: Text(
                      cli.nombre.isNotEmpty ? cli.nombre[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(cli.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                        icon: const Icon(Icons.edit, color: Colors.indigo),
                        onPressed: () => _mostrarFormulario(cliente: cli),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _firestoreService.deleteCliente(cli.id!),
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