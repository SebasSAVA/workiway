import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workiway/widgets/product_card.dart'; // Asegúrate de crear este widget también
import 'package:workiway/widgets/product_detail_sreen.dart';
import 'add_product_screen.dart'; // Asegúrate de importar la pantalla para agregar productos

class ProviderProductsScreen extends StatelessWidget {
  final String? userUid;

  const ProviderProductsScreen({Key? key, this.userUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF438ef9),
        title: const Text('Todos mis Productos',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Redirigir a la pantalla de agregar producto
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProductScreen(
                      userUid:
                          userUid), // Asegúrate de pasar el userUid si lo necesitas
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('productos')
            .where('providerId',
                isEqualTo: userUid) // Escuchar cambios en tiempo real
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No tienes productos disponibles.'));
          }

          return FutureBuilder<Map<String, dynamic>?>(
            future: _getProviderData(userUid!), // Obtener datos del proveedor
            builder: (context, providerSnapshot) {
              if (providerSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (providerSnapshot.hasError) {
                return Center(
                    child: Text(
                        'Error al cargar los datos del proveedor: ${providerSnapshot.error}'));
              }

              final providerData = providerSnapshot.data;

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final product =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;

                  // Obtener la URL de la foto de perfil del proveedor
                  final providerImageUrl = providerData?['fotoPerfil'] ?? '';

                  // Construir el nombre del proveedor
                  final providerName = providerData != null
                      ? '${providerData['nombre'] ?? ''} ${providerData['apellidos'] ?? ''}'
                          .trim()
                      : 'Sin nombre';

                  // Envolver la tarjeta de producto en InkWell para detectar toques
                  return InkWell(
                    onTap: () {
                      final docId = snapshot
                          .data!.docs[index].id; // Obtener el ID del producto
                      final product = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;

                      // Navegar a la pantalla de detalles del producto al hacer clic
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            productData: {
                              ...product,
                              'id': docId, // Pasar el ID del producto
                              'providerName': providerName,
                              'providerImageUrl': providerImageUrl,
                            },
                          ),
                        ),
                      );
                    },
                    child: ProductCard(
                      category: product['category'] ?? 'Sin categoría',
                      title: product['name'] ?? 'Sin título',
                      price: (product['price']?.toDouble() ?? 0.0),
                      condition: product['condition'] ?? 'Sin condición',
                      providerName:
                          providerName.isNotEmpty ? providerName : 'Sin nombre',
                      imageUrl: product['imageUrl'] ?? '',
                      providerImageUrl: providerImageUrl,
                      stock: product['stock'] ??
                          0, // Asegúrate de que este campo esté en la BD
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Método para obtener los datos del proveedor
  Future<Map<String, dynamic>?> _getProviderData(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('proveedores') // Cambiar a 'proveedores'
        .doc(uid)
        .get();

    return snapshot.data(); // Retorna los datos del proveedor
  }
}
