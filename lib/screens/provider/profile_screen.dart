import 'package:flutter/material.dart';
import 'package:workiway/services/user_service.dart';
import 'package:workiway/widgets/ConfirmationDialogWithButtons.dart';
import 'package:workiway/widgets/profile%20_header.dart';
import 'package:workiway/widgets/profile_option.dart';
import 'package:workiway/widgets/profile_options_list.dart';
import 'edit_profile_screen.dart'; // Importamos la nueva pantalla de edición
import 'provider_services_screen.dart'; // Importamos la nueva pantalla de servicios
import 'provider_products_screen.dart'; // Importa la nueva pantalla de productos

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  _ProviderProfileScreenState createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  final UserService _userService = UserService();
  Map<String, dynamic>? userData;
  String? userUid; // Variable para almacenar el uid del usuario

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Cargar datos al iniciar
  }

  Future<void> _loadUserData() async {
    Map<String, dynamic>? data = await _userService.getUserData();
    setState(() {
      userData = data;
      userUid = userData?['uid']; // Almacena el uid del usuario
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
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              children: [
                ProfileHeader(
                  imageUrl: userData!['fotoPerfil'] != null &&
                          userData!['fotoPerfil'].isNotEmpty
                      ? NetworkImage(userData!['fotoPerfil'])
                      : const AssetImage(
                          'lib/assets/images/default_profile.png'),
                  name:
                      '${userData!['nombre'] ?? 'Nombre'} ${userData!['apellidos'] ?? 'Apellido'}',
                  email: userData!['email'] ?? 'No disponible',
                  userType: 'Proveedor',
                  onEdit: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(
                          nombre: userData!['nombre'],
                          apellidos: userData!['apellidos'],
                          telefono: userData!['telefono'],
                        ),
                      ),
                    );
                    _loadUserData();
                  },
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ProfileOptionsList(
                    options: [
                      ProfileOption(
                        icon: Icons.build,
                        text: 'Servicios',
                        onTap: () {
                          print('User UID: $userUid'); // Ejemplo de uso del UID
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProviderServicesScreen(
                                  userUid: userUid), // Pasar el uid
                            ),
                          );
                        },
                      ),
                      ProfileOption(
                        icon: Icons.shopping_bag,
                        text: 'Productos',
                        onTap: () {
                          print('User UID: $userUid'); // Ejemplo de uso del UID
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProviderProductsScreen(
                                  userUid: userUid), // Pasar el uid
                            ),
                          );
                        },
                      ),
                      //ProfileOption(
                      //icon: Icons.monetization_on,
                      //text: 'Información de Cobro',
                      //onTap: () {
                      //  print('Información de Cobro');
                      //},
                      //),
                      ProfileOption(
                        icon: Icons.exit_to_app,
                        text: 'Cerrar sesión',
                        onTap: _showLogoutConfirmationDialog,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
