import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener datos del proveedor
  Future<Map<String, dynamic>?> getProviderData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('proveedores').doc(user.uid).get();
      return doc.data(); // Devuelve los datos del proveedor
    }
    return null;
  }
}
