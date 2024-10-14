import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createProduct(Map<String, dynamic> productData) async {
    try {
      await _firestore.collection('productos').add(productData);
    } catch (e) {
      throw Exception('Error al crear el producto: $e');
    }
  }

  // Aquí puedes agregar métodos adicionales relacionados con la colección de productos
}
