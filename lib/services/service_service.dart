import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createService(Map<String, dynamic> serviceData) async {
    try {
      await _firestore.collection('servicios').add(serviceData);
    } catch (e) {
      throw Exception('Error al crear el servicio: $e');
    }
  }

  // Aquí puedes agregar métodos adicionales relacionados con la colección de servicios
}
