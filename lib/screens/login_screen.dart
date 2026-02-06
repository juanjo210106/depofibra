import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Variable para saber si está cargando y mostrar un "spinner"
  bool _isLoading = false;

  void _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
    });

    final authService = AuthService();
    final user = await authService.signInWithGoogle();

    // Si el login falla o se cancela, quitamos el spinner
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
    }
    // NOTA: Si el login es exitoso, el 'StreamBuilder' en main.dart (que haremos al final)
    // detectará el cambio y nos llevará automágicamente al Home.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. LOGO o ÍCONO
              Icon(
                Icons.water_drop_rounded, // Representando líquidos/agua
                size: 100,
                color: Color(0xFF01488e), // Tu azul corporativo
              ),
              SizedBox(height: 20),

              // 2. TÍTULO
              Text(
                'Depofibra',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF01488e),
                ),
              ),
              Text(
                'Gestión de Depósitos y Piscinas',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 50),

              // 3. BOTÓN DE LOGIN (O Spinner de carga)
              _isLoading
                  ? CircularProgressIndicator(color: Color(0xFF01488e))
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 3,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: Icon(Icons.login, color: Color(0xFF01488e)),
                      label: Text(
                        'Iniciar sesión con Google',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: _handleGoogleLogin,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}