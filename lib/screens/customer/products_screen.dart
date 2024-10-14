import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workiway/widgets/product_card.dart'; // Asegúrate de crear este widget también

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('productos') // Obtener todos los productos
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay productos disponibles.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final product =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              // Obtener el providerId del producto
              final providerId = product['providerId'];

              // FutureBuilder para obtener los datos del proveedor
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('proveedores') // Colección de proveedores
                    .doc(
                        providerId) // Usar el providerId para obtener el documento
                    .get(),
                builder: (context, providerSnapshot) {
                  if (providerSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (providerSnapshot.hasError) {
                    return Center(
                        child: Text(
                            'Error al cargar proveedor: ${providerSnapshot.error}'));
                  }
                  if (!providerSnapshot.hasData ||
                      !providerSnapshot.data!.exists) {
                    return const Center(
                        child: Text('Proveedor no encontrado.'));
                  }

                  // Obtener los datos del proveedor
                  final providerData =
                      providerSnapshot.data!.data() as Map<String, dynamic>;
                  final providerName =
                      '${providerData['nombre'] ?? ''} ${providerData['apellidos'] ?? ''}'
                          .trim();
                  final providerImageUrl = providerData['fotoPerfil'] ?? '';

                  return ProductCard(
                    category: product['category'] ?? 'Sin categoría',
                    title: product['name'] ?? 'Sin título',
                    price: product['price']?.toDouble() ?? 0.0,
                    condition: product['condition'] ?? 'Sin condición',
                    providerName:
                        providerName.isNotEmpty ? providerName : 'Sin nombre',
                    imageUrl: product['imageUrl'] ?? '',
                    providerImageUrl: providerImageUrl,
                    stock: product['stock'] ?? 0,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
