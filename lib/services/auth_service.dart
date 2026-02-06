import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Instancias de Firebase y Google
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Este "Stream" es como una tubería que nos avisa si el usuario
  // está logueado o no. Lo usaremos para cambiar entre la pantalla de Login y la Home automáticamente.
  Stream<User?> get usuarioActual => _auth.authStateChanges();

  // Función para iniciar sesión con Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Iniciar el flujo de login de Google (abre la ventana de elegir cuenta)
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return null; // El usuario canceló el login

      // 2. Obtener los detalles de autenticación de la solicitud
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Crear una credencial nueva para Firebase con los tokens de Google
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Iniciar sesión en Firebase con esa credencial
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Error en login: $e");
      return null;
    }
  }

  // Función para cerrar sesión
  Future<void> signOut() async {
    await _googleSignIn.signOut(); // Salir de Google
    await _auth.signOut();         // Salir de Firebase
  }
}