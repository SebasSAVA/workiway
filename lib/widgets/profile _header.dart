import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final ImageProvider imageUrl;
  final String name;
  final String email;
  final String userType;
  final VoidCallback onEdit;

  const ProfileHeader({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.email,
    required this.userType,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: imageUrl, // Aquí usamos ImageProvider
            ),
            Positioned(
              bottom: 0,
              right: 4,
              child: Material(
                type: MaterialType
                    .transparency, // Necesario para que funcione InkWell
                child: InkWell(
                  onTap: onEdit,
                  splashColor:
                      Colors.white.withOpacity(0.3), // Efecto al hacer clic
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.all(
                        2.0), // Ajustamos el padding para cubrir bien el área de clic
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: const Color(0xFF438ef9),
                      child:
                          const Icon(Icons.edit, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          userType,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
