import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener datos del cliente o proveedor según el tipo de usuario
  Future<Map<String, dynamic>?> getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Determinar si el usuario es cliente o proveedor
      bool esCliente = await _esCliente(user.uid);
      String collection = esCliente ? 'clientes' : 'proveedores';

      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection(collection).doc(user.uid).get();
      return doc.data(); // Devuelve los datos del cliente/proveedor
    }
    return null;
  }

  // Determinar si el usuario es un cliente
  Future<bool> _esCliente(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await _firestore.collection('clientes').doc(uid).get();
    return doc.exists;
  }

  // Función para cerrar sesión
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}
