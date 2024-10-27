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

  // Método para actualizar un producto existente
  Future<void> updateProduct(
      String productId, Map<String, dynamic> productData) async {
    try {
      await _firestore
          .collection('productos')
          .doc(productId)
          .update(productData);
    } catch (e) {
      throw Exception('Error al actualizar el producto: $e');
    }
  }
}
