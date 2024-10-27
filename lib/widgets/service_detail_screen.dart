import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workiway/screens/provider/add_service_screen.dart';
import 'package:workiway/screens/provider/provider_services_screen.dart';
import 'package:workiway/widgets/ConfirmationDialogWithButtons.dart';
import 'package:workiway/widgets/ConfirmationScreen.dart';

class ServiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> serviceData;

  const ServiceDetailScreen({Key? key, required this.serviceData})
      : super(key: key);

  // Función para eliminar el servicio
  Future<void> _eliminarServicio(BuildContext parentContext) async {
    try {
      print('ID del documento a eliminar: "${serviceData['id']}"');
      final idLimpio = serviceData['id'].toString().trim();
      final docRef =
          FirebaseFirestore.instance.collection('servicios').doc(idLimpio);

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docSnapshot.reference.delete();
        print('Documento eliminado correctamente.');

        // Navegar a la pantalla de confirmación
        Navigator.of(parentContext).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ConfirmationScreen(
              mensaje: '¡Servicio eliminado con éxito!',
              icono: Icons.check_circle,
              onButtonPressed: () {
                // Navegar a ProviderServicesScreen al hacer clic en el botón de confirmación
                Navigator.of(parentContext).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => ProviderServicesScreen(
                      userUid: serviceData[
                          'providerId'], // Pasar el UID del proveedor si es necesario
                    ),
                  ),
                  (Route<dynamic> route) =>
                      false, // Eliminar todas las pantallas anteriores
                );
              },
            ),
          ),
        );
      } else {
        print('El documento no existe.');
        ScaffoldMessenger.of(parentContext).showSnackBar(
          const SnackBar(content: Text('El servicio no existe.')),
        );
      }
    } on FirebaseException catch (e) {
      print('FirebaseException: ${e.message}');
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(content: Text('Error al eliminar servicio: ${e.message}')),
      );
    } catch (e) {
      print('Error inesperado: $e');
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(content: Text('Error al eliminar servicio: $e')),
      );
    }
  }

  // Función para mostrar el diálogo de confirmación
  void _showDeleteConfirmationDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return ConfirmationDialogWithButtons(
          mensaje: '¿Estás seguro de que deseas eliminar este servicio?',
          icono: Icons.warning,
          onAcceptPressed: () async {
            Navigator.of(context).pop(); // Cierra el diálogo
            await _eliminarServicio(parentContext); // Ejecuta la eliminación
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
    final bool paymentAdvance = serviceData['isPaymentAdvance'] ?? false;
    final int paymentPercentage = serviceData['paymentPercentage'] != null
        ? int.tryParse(serviceData['paymentPercentage'].toString()) ?? 0
        : 0;

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
              serviceData['imageUrl'] ?? '',
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      serviceData['description'] ?? 'Sin descripción',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    Text('Distritos',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...?serviceData['districts']?.map<Widget>((district) {
                      return Text(
                        '- $district',
                        style: TextStyle(fontSize: 16),
                      );
                    }),
                    const SizedBox(height: 16),
                    Text('Disponibilidad',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...?serviceData['availability']?.entries.map((entry) {
                      final day = entry.key;
                      final times = entry.value;
                      return Text(
                        '$day: ${times['start']} - ${times['end']}',
                        style: TextStyle(fontSize: 16),
                      );
                    }),
                    const SizedBox(height: 16),
                    Text('Reseñas',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      'No hay comentarios.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
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
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        serviceData['category'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '>',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        serviceData['subCategory'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5958B2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star_border,
                        color: Color(0xFFF4C01E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    serviceData['name'] ?? 'Sin título',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'S/ ${serviceData['price'] ?? '0.00'}',
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        serviceData['paymentModalidad'] ?? 'Sin modalidad',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    paymentAdvance
                        ? 'Pago por adelantado: $paymentPercentage%'
                        : 'No requiere pago por adelantado',
                    style: TextStyle(
                      fontSize: 14,
                      color: paymentAdvance ? Colors.green : Colors.red,
                    ),
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF737373),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF737373),
                  ),
                  child: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'editar') {
                        // Asegúrate de que el ID del servicio se pase correctamente dentro de serviceData
                        final Map<String, dynamic> updatedServiceData = {
                          ...serviceData,
                          'id': serviceData['id'],
                        };

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddServiceScreen(
                              isEditing: true,
                              existingService: {
                                ...updatedServiceData, // Asegúrate de que contenga todos los datos
                                'id': serviceData[
                                    'id'], // Pasar el ID explícitamente
                              },
                              userUid: serviceData['providerId'],
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
