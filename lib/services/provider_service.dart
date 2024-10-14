import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderService {
  Future<void> actualizarDatosProveedor({
    required String nombre,
    required String apellidos,
    required String telefono,
    required List<String> departamentos,
    required List<String> provincias,
    required String sobreTi,
    required String porQueElegirme,
    required String? fotoPerfil, // Añadimos el parámetro para la foto de perfil
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userId = user.uid;

      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('proveedores').doc(userId);

      try {
        DocumentSnapshot docSnapshot = await userDocRef.get();

        if (docSnapshot.exists) {
          await userDocRef.update({
            'nombre': nombre,
            'apellidos': apellidos,
            'telefono': telefono,
            'departamentos': departamentos,
            'provincias': provincias,
            'sobreTi': sobreTi,
            'porQueElegirme': porQueElegirme,
            'fotoPerfil': fotoPerfil, // Guardamos la URL de la imagen
          });
        } else {
          await userDocRef.set({
            'nombre': nombre,
            'apellidos': apellidos,
            'telefono': telefono,
            'departamentos': departamentos,
            'provincias': provincias,
            'sobreTi': sobreTi,
            'porQueElegirme': porQueElegirme,
            'fotoPerfil':
                fotoPerfil, // Guardamos la URL de la imagen en un nuevo documento
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
  Future<DocumentSnapshot> obtenerDatosProveedor() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userId = user.uid;
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('proveedores').doc(userId);

      return await userDocRef.get();
    } else {
      throw Exception('Usuario no autenticado');
    }
  }
}
