import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String category; // Categoría del producto
  final String title; // Título del producto
  final double price; // Precio del producto
  final String condition; // Condición del producto
  final String providerName; // Nombre del proveedor
  final String imageUrl; // Imagen del producto
  final String providerImageUrl; // URL de la imagen del proveedor
  final int stock; // Stock del producto

  const ProductCard({
    Key? key,
    required this.category,
    required this.title,
    required this.price,
    required this.condition,
    required this.providerName,
    required this.imageUrl,
    required this.providerImageUrl,
    required this.stock, // Agregar stock
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3), // Cambia la posición de la sombra
          ),
        ],
      ),
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del producto
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Categoría del producto
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estrellas
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star_border,
                      color: const Color(0xFFF4C01E), // Color amarillo deseado
                    );
                  }),
                ),
                const SizedBox(height: 5),
                // Título del producto
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20, // Tamaño grande
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                // Precio del producto
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'S/ ${price.toStringAsFixed(2)}', // Precio
                      style: const TextStyle(
                        fontSize: 24, // Tamaño grande para el precio
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      condition, // Condición del producto
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // Stock del producto
                Text(
                  'Stock: $stock', // Mostrar stock
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 10),
                // Nombre del proveedor con foto circular
                Row(
                  children: [
                    ClipOval(
                      child: providerImageUrl.isNotEmpty
                          ? Image.network(
                              providerImageUrl,
                              width: 50, // Tamaño de la imagen circular
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'lib/assets/images/default_profile.png', // Carga la imagen local si es nula o vacía
                              width: 50, // Tamaño de la imagen circular
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(
                        width: 8), // Espacio entre la imagen y el nombre
                    Text(
                      providerName,
                      style: const TextStyle(
                          fontSize: 16, // Tamaño del texto del nombre
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
