import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / Icono Corporativo
              const Icon(
                Icons.water_drop_rounded,
                size: 100,
                color: Color(0xFF01488e),
              ),
              const SizedBox(height: 20),

              // Título
              const Text(
                'Depofibra',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF01488e),
                ),
              ),
              const Text(
                'Gestión Integral',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 60),

              // Botón de Login o Carga
              if (_isLoading)
                const CircularProgressIndicator(color: Color(0xFF01488e))
              else
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01488e),
                    foregroundColor: Colors.white, // Texto blanco
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.login),
                  label: const Text(
                    'Iniciar sesión con Google',
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    // Llamamos al servicio que creamos antes
                    await AuthService().signInWithGoogle(context);
                    if (mounted) {
                      setState(() => _isLoading = false);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}