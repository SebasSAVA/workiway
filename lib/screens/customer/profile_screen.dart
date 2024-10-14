import 'package:flutter/material.dart';
import 'package:workiway/screens/customer/edit_profile_screen.dart';
import 'package:workiway/services/user_service.dart';
import 'package:workiway/widgets/ConfirmationDialogWithButtons.dart';
import 'package:workiway/widgets/profile%20_header.dart';
import 'package:workiway/widgets/profile_option.dart';
import 'package:workiway/widgets/profile_options_list.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  _CustomerProfileScreenState createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final UserService _userService = UserService();
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Cargar datos al iniciar
  }

  Future<void> _loadUserData() async {
    Map<String, dynamic>? data = await _userService.getUserData();
    setState(() {
      userData = data;
    });
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialogWithButtons(
          mensaje: '¿Estás seguro de que deseas cerrar sesión?',
          icono: Icons.logout,
          onAcceptPressed: () async {
            await _userService.cerrarSesion();
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
          },
          onCancelPressed: () {
            Navigator.of(context).pop(); // Cierra el diálogo sin cerrar sesión
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return userData == null
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding:
                const EdgeInsets.only(top: 20.0), // Margen superior agregado
            child: Column(
              children: [
                // Header de perfil con foto, nombres, apellidos, email y tipo de usuario
                ProfileHeader(
                  imageUrl: userData!['fotoPerfil'] != null &&
                          userData!['fotoPerfil'].isNotEmpty
                      ? NetworkImage(userData!['fotoPerfil']) // Imagen de red
                      : const AssetImage(
                          'lib/assets/images/default_profile.png'), // Imagen local por defecto
                  // Concatenamos nombre y apellido
                  name:
                      '${userData!['nombre'] ?? 'Nombre'} ${userData!['apellidos'] ?? 'Apellido'}',
                  email: userData!['email'] ?? 'No disponible',
                  userType: 'Cliente', // Tipo de usuario (Cliente)
                  onEdit: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditCustomerProfileScreen(
                          nombre: userData!['nombre'],
                          apellidos: userData!['apellidos'],
                          telefono: userData!['telefono'],
                        ),
                      ),
                    );
                    // Recargar los datos al volver de la pantalla de edición
                    _loadUserData();
                  },
                ),
                const SizedBox(height: 30),

                // Usamos el ProfileOptionsList para organizar las opciones
                Expanded(
                  child: ProfileOptionsList(
                    options: [
                      ProfileOption(
                        icon: Icons.star,
                        text: 'Servicios Favoritos',
                        onTap: () {
                          print('Servicios Favoritos');
                        },
                      ),
                      ProfileOption(
                        icon: Icons.shopping_bag,
                        text: 'Productos Favoritos',
                        onTap: () {
                          print('Productos Favoritos');
                        },
                      ),
                      ProfileOption(
                        icon: Icons.person_search,
                        text: 'Proveedores Favoritos',
                        onTap: () {
                          print('Proveedores Favoritos');
                        },
                      ),
                      ProfileOption(
                        icon: Icons.rate_review,
                        text: 'Mis reseñas',
                        onTap: () {
                          print('Mis reseñas');
                        },
                      ),
                      ProfileOption(
                        icon: Icons.exit_to_app,
                        text: 'Cerrar sesión',
                        onTap:
                            _showLogoutConfirmationDialog, // Muestra el diálogo de confirmación
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
