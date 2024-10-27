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

  /// Método para actualizar un servicio
  Future<void> updateService(
      String serviceId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('services').doc(serviceId).update(data);
    } catch (e) {
      throw Exception('Error al actualizar servicio: $e');
    }
  }

  // Aquí puedes agregar métodos adicionales relacionados con la colección de servicios
}
