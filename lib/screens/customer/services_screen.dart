import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workiway/widgets/service_card.dart'; // Asegúrate de crear este widget también

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('servicios') // Obtener todos los servicios
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay servicios disponibles.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final service =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              // Obtener el providerId del servicio
              final providerId = service['providerId'];

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

                  return ServiceCard(
                    category: service['category'] ?? 'Sin categoría',
                    title: service['name'] ?? 'Sin título',
                    price: (service['price']?.toDouble() ?? 0.0),
                    modality: service['paymentModalidad'] ?? 'Sin modalidad',
                    providerName:
                        providerName.isNotEmpty ? providerName : 'Sin nombre',
                    imageUrl: service['imageUrl'] ?? '',
                    providerImageUrl: providerImageUrl,
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
