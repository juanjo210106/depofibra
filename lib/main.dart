import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  // Aseguramos que el motor gráfico de Flutter esté listo
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos Firebase (Buscará automáticamente google-services.json)
  await Firebase.initializeApp();

  runApp(const DepofibraApp());
}

class DepofibraApp extends StatelessWidget {
  const DepofibraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Quitamos la etiqueta "Debug"
      title: 'Depofibra',
      
      // TEMA GLOBAL
      theme: ThemeData(
        primaryColor: const Color(0xFF01488e),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF01488e),
          primary: const Color(0xFF01488e), // Forzamos el color primario
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF01488e),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),

      // GESTOR DE ESTADO (Login vs Home)
      // Escuchamos los cambios de autenticación de Firebase en tiempo real
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Si Firebase está comprobando el estado, mostramos carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Si hay usuario activo, vamos al Home
          if (snapshot.hasData) {
            return const HomeScreen();
          }

          // Si no hay usuario, vamos al Login
          return const LoginScreen();
        },
      ),
    );
  }
}