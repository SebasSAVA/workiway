import 'package:flutter/material.dart';
import 'package:workiway/services/user_service.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  _ProviderProfileScreenState createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  final UserService _userService = UserService();
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    Map<String, dynamic>? data = await _userService.getUserData();
    setState(() {
      userData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (userData != null) ...[
            Text('Nombre: ${userData!['nombre'] ?? 'No disponible'}'),
            Text('Email: ${userData!['email'] ?? 'No disponible'}'),
            Text('Teléfono: ${userData!['telefono'] ?? 'No disponible'}'),
          ] else
            const CircularProgressIndicator(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await _userService.cerrarSesion();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false);
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
