import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workiway/screens/provider/add_product_screen.dart';
import 'package:workiway/widgets/ConfirmationDialogWithButtons.dart';
import 'package:workiway/widgets/ConfirmationScreen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> productData;

  const ProductDetailScreen({Key? key, required this.productData})
      : super(key: key);

  // Función para eliminar el producto
  Future<void> _eliminarProducto(BuildContext parentContext) async {
    try {
      print('ID del producto a eliminar: "${productData['id']}"');
      final idLimpio = productData['id'].toString().trim();
      final docRef =
          FirebaseFirestore.instance.collection('productos').doc(idLimpio);

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docSnapshot.reference.delete();
        print('Producto eliminado correctamente.');

        // Navegar a la pantalla de confirmación
        Navigator.of(parentContext).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ConfirmationScreen(
              mensaje: '¡Producto eliminado con éxito!',
              icono: Icons.check_circle,
              onButtonPressed: () {
                Navigator.popUntil(parentContext, (route) => route.isFirst);
              },
            ),
          ),
        );
      } else {
        print('El producto no existe.');
        ScaffoldMessenger.of(parentContext).showSnackBar(
          const SnackBar(content: Text('El producto no existe.')),
        );
      }
    } on FirebaseException catch (e) {
      print('FirebaseException: ${e.message}');
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(content: Text('Error al eliminar producto: ${e.message}')),
      );
    } catch (e) {
      print('Error inesperado: $e');
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(content: Text('Error al eliminar producto: $e')),
      );
    }
  }

  // Función para mostrar el diálogo de confirmación
  void _showDeleteConfirmationDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return ConfirmationDialogWithButtons(
          mensaje: '¿Estás seguro de que deseas eliminar este producto?',
          icono: Icons.warning,
          onAcceptPressed: () async {
            Navigator.of(context).pop(); // Cierra el diálogo
            await _eliminarProducto(parentContext); // Ejecuta la eliminación
          },
          onCancelPressed: () {
            Navigator.of(context).pop(); // Cierra el diálogo sin eliminar
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240,
            child: Image.network(
              productData['imageUrl'] ?? '',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            top: 280,
            child: Container(
              color: const Color(0xFFF4F6FF),
              padding: const EdgeInsets.only(top: 80, left: 16, right: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Descripción',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      productData['description'] ?? 'Sin descripción',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    // Condición con título en negrita y valor abajo
                    Text('Condición',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      productData['condition'] ?? 'N/A',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 160,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        productData['category'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(
                      5,
                      (index) => const Icon(
                        Icons.star_border,
                        color: Color(0xFFF4C01E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    productData['name'] ?? 'Sin nombre',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Precio y stock en la misma línea
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'S/ ${productData['price'] ?? '0.00'}',
                        style: const TextStyle(
                          fontSize: 26,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Stock: ${productData['stock'] ?? 0}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF737373),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF737373),
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'editar') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddProductScreen(
                              isEditing: true,
                              existingProduct: {
                                ...productData,
                                'id': productData[
                                    'id'], // Pasar explícitamente el ID
                              },
                            ),
                          ),
                        );
                      } else if (value == 'eliminar') {
                        _showDeleteConfirmationDialog(context);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem(
                          value: 'editar',
                          child: Text('Editar'),
                        ),
                        const PopupMenuItem(
                          value: 'eliminar',
                          child: Text('Eliminar'),
                        ),
                      ];
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
