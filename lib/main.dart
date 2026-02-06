import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// IMPORTANTE: Este archivo se genera automáticamente al configurar Firebase
// Si te da error, recuerda ejecutar 'flutterfire configure' en tu terminal
import 'firebase_options.dart';

import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  // Aseguramos que el motor de Flutter esté listo antes de llamar a código nativo
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos Firebase con la configuración de tu proyecto
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(DepofibraApp());
}

class DepofibraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Quitamos la etiqueta "DEBUG"
      title: 'Depofibra',
      
      // TEMA GLOBAL: Aquí definimos tu color corporativo para toda la app
      theme: ThemeData(
        primaryColor: Color(0xFF01488e),
        useMaterial3: true, // Diseño moderno
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF01488e), // Tu azul genera toda la paleta
          primary: Color(0xFF01488e),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF01488e),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),

      // EL CEREBRO DE LA NAVEGACIÓN:
      // Escuchamos el estado de la autenticación en tiempo real
      home: StreamBuilder<User?>(
        stream: AuthService().usuarioActual,
        builder: (context, snapshot) {
          // Si la conexión está esperando, podríamos mostrar un spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Si hay datos (usuario existe), vamos al Home
          if (snapshot.hasData) {
            return HomeScreen();
          }

          // Si no hay datos, vamos al Login
          return LoginScreen();
        },
      ),
    );
  }
}