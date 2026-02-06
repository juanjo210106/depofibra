import 'package:flutter/material.dart';
import '../services/auth_service.dart';
// Estas pantallas las crearemos a continuación:
import 'productos_screen.dart';
import 'clientes_screen.dart';
import 'pedidos_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Depofibra Panel'),
        backgroundColor: const Color(0xFF01488e), // Tu azul corporativo
        foregroundColor: Colors.white,
        actions: [
          // Botón de salir
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => AuthService().signOut(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Menú de Gestión',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF01488e)),
            ),
            const SizedBox(height: 20),
            
            // Grid de navegación
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // 2 columnas
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _MenuCard(
                    icon: Icons.water_damage,
                    title: 'Productos',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProductosScreen()),
                      );
                    },
                  ),
                  _MenuCard(
                    icon: Icons.people,
                    title: 'Clientes',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ClientesScreen()),
                      );
                    },
                  ),
                  _MenuCard(
                    icon: Icons.shopping_cart,
                    title: 'Pedidos',
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PedidosScreen()),
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

// Widget privado para las tarjetas del menú (Todo en un solo archivo)
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
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
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}