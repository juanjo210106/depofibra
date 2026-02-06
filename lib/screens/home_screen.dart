import 'package:flutter/material.dart';
import '../services/auth_service.dart';
// Estas importaciones darán error hasta que creemos los archivos en los siguientes pasos
import 'productos_screen.dart';
import 'clientes_screen.dart';
import 'pedidos_screen.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Depofibra Panel'),
        backgroundColor: Color(0xFF01488e), // Azul corporativo
        foregroundColor: Colors.white, // Texto blanco
        actions: [
          // Botón de Cerrar Sesión
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await _auth.signOut();
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Bienvenido a la gestión',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Usamos Expanded para que el Grid ocupe el espacio restante
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // 2 columnas
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _MenuCard(
                    icon: Icons.water_damage, // Icono de depósito
                    label: 'Productos',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProductosScreen()),
                      );
                    },
                  ),
                  _MenuCard(
                    icon: Icons.people,
                    label: 'Clientes',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ClientesScreen()),
                      );
                    },
                  ),
                  _MenuCard(
                    icon: Icons.shopping_cart,
                    label: 'Pedidos',
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PedidosScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget auxiliar privado para no repetir código en las tarjetas
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 35, color: color),
            ),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}