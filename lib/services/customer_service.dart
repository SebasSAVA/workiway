import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerService {
  Future<void> actualizarDatosCliente({
    required String nombre,
    required String apellidos,
    required String telefono,
    required String departamento, // Campo único
    required String provincia, // Campo único
    required String? fotoPerfil,
    required String direccion, // Añadimos el parámetro para la dirección
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userId = user.uid;

      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('clientes').doc(userId);

      try {
        DocumentSnapshot docSnapshot = await userDocRef.get();

        if (docSnapshot.exists) {
          await userDocRef.update({
            'nombre': nombre,
            'apellidos': apellidos,
            'telefono': telefono,
            'departamento': departamento, // Guardamos el único dato
            'provincia': provincia, // Guardamos el único dato
            'fotoPerfil': fotoPerfil, // Guardamos la URL de la imagen
            'direccion': direccion, // Guardamos la dirección
          });
        } else {
          await userDocRef.set({
            'nombre': nombre,
            'apellidos': apellidos,
            'telefono': telefono,
            'departamento': departamento, // Guardamos el único dato
            'provincia': provincia, // Guardamos el único dato
            'fotoPerfil':
                fotoPerfil, // Guardamos la URL de la imagen en un nuevo documento
            'direccion': direccion, // Guardamos la dirección
            'uid': userId,
          });
        }
      } catch (e) {
        throw Exception('Error al actualizar los datos: $e');
      }
    } else {
      throw Exception('Usuario no autenticado');
    }
  }

  // Función para obtener los datos del perfil
  Future<DocumentSnapshot> obtenerDatosCliente() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userId = user.uid;
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('clientes').doc(userId);

      return await userDocRef.get();
    } else {
      throw Exception('Usuario no autenticado');
    }
  }
}
