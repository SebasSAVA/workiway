import 'package:flutter/material.dart';
import 'package:workiway/widgets/service_card.dart';
import 'package:workiway/widgets/service_detail_screen.dart';
import 'add_service_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderServicesScreen extends StatelessWidget {
  final String? userUid; // Agregar una variable para el uid

  const ProviderServicesScreen({Key? key, this.userUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF438ef9),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Todos mis Servicios',
            style: TextStyle(color: Colors.white),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddServiceScreen(userUid: userUid),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('servicios')
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
                child: Text('No tienes servicios disponibles.'));
          }

          // Obtener datos del proveedor
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
                  final service =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;

                  // Obtener la URL de la foto de perfil del proveedor
                  final providerImageUrl = providerData?['fotoPerfil'] ?? '';

                  // Construir el nombre del proveedor
                  final providerName = providerData != null
                      ? '${providerData['nombre'] ?? ''} ${providerData['apellidos'] ?? ''}'
                          .trim()
                      : 'Sin nombre';

                  // Envolver la carta en InkWell para detectar toques
                  return InkWell(
                    onTap: () {
                      final docId = snapshot
                          .data!.docs[index].id; // Obtener el ID del documento
                      final service = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;
                      // Navegar a la pantalla de detalles del servicio al hacer clic
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceDetailScreen(
                            serviceData: {
                              ...service,
                              'id': docId, // Pasar el ID del documento
                              'providerName': providerName,
                              'providerImageUrl': providerImageUrl,
                            },
                          ),
                        ),
                      );
                    },
                    child: ServiceCard(
                      category: service['category'] ?? 'Sin categoría',
                      title: service['name'] ?? 'Sin título',
                      price: (service['price']?.toDouble() ?? 0.0),
                      modality: service['paymentModalidad'] ?? 'Sin modalidad',
                      providerName:
                          providerName.isNotEmpty ? providerName : 'Sin nombre',
                      imageUrl: service['imageUrl'] ?? '',
                      providerImageUrl: providerImageUrl,
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
        .collection('proveedores')
        .doc(uid)
        .get();

    return snapshot.data(); // Retorna los datos del proveedor
  }
}
