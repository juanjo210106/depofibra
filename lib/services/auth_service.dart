import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/login_screen.dart'; // Usaremos LoginScreen en lugar de AuthScreen

class AuthService {
  // Instancias de Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Método para iniciar sesión con Google
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // 1. Abrir ventana de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // Usuario canceló

      // 2. Obtener credenciales
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Login en Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // 4. Guardar datos del usuario en Firestore (Opcional pero recomendado)
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'nombre': user.displayName ?? 'Usuario',
          'email': user.email,
          'ultimo_login': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // 5. Ir a la Home
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      print("Error en Login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al conectar: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // Cerrar sesión
  Future<void> signOut(BuildContext context) async {
    await _googleSignIn.signOut();
    await _auth.signOut();

    // Volver al Login
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  // Getter útil para saber si hay usuario activo
  User? get currentUser => _auth.currentUser;
}