import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Función para registrar usuario como cliente o proveedor
  Future<String?> registrarUsuario(
    String nombre,
    String apellidos,
    String telefono,
    String email,
    String password,
    String tipoUsuario,
  ) async {
    try {
      // Crear usuario en Firebase Authentication
      UserCredential credencialesUsuario =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Enviar correo de verificación
      await credencialesUsuario.user?.sendEmailVerification();

      // Guardar datos en Firestore en colecciones separadas
      if (tipoUsuario == 'Cliente') {
        await _firestore
            .collection('clientes')
            .doc(credencialesUsuario.user!.uid)
            .set({
          'nombre': nombre,
          'apellidos': apellidos,
          'telefono': telefono,
          'email': email,
          'tipoUsuario': tipoUsuario,
          'uid': credencialesUsuario.user!.uid,
          'emailVerified': false,
        });
      } else if (tipoUsuario == 'Proveedor') {
        await _firestore
            .collection('proveedores')
            .doc(credencialesUsuario.user!.uid)
            .set({
          'nombre': nombre,
          'apellidos': apellidos,
          'telefono': telefono,
          'email': email,
          'tipoUsuario': tipoUsuario,
          'uid': credencialesUsuario.user!.uid,
          'emailVerified': false,
        });
      }

      return 'Registro exitoso. Revisa tu correo para verificar tu cuenta antes de iniciar sesión.';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Este correo ya está registrado. Intenta con otro.';
      } else {
        return e.message;
      }
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  Future<void> actualizarEmailVerificado(User user) async {
    await user.reload(); // Recargar estado del usuario
    if (user.emailVerified) {
      // Actualiza la verificación de correo en la colección correspondiente
      if (await esCliente(user.uid)) {
        await _firestore.collection('clientes').doc(user.uid).update({
          'emailVerified': true,
        });
      } else {
        await _firestore.collection('proveedores').doc(user.uid).update({
          'emailVerified': true,
        });
      }
    }
  }

  // Función para verificar si el correo ha sido validado y actualizar Firestore
  Future<void> verificarCorreo(User user) async {
    await user.reload(); // Recargar estado del usuario
    if (user.emailVerified) {
      // Actualiza la verificación de correo en la colección correspondiente
      if (await esCliente(user.uid)) {
        await _firestore.collection('clientes').doc(user.uid).update({
          'emailVerified': true,
        });
      } else {
        await _firestore.collection('proveedores').doc(user.uid).update({
          'emailVerified': true,
        });
      }
    }
  }

  // Función para saber si el usuario es Cliente
  Future<bool> esCliente(String uid) async {
    final doc = await _firestore.collection('clientes').doc(uid).get();
    return doc.exists;
  }
}
