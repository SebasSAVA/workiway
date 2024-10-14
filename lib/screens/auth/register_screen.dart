import 'package:flutter/material.dart';
import 'package:workiway/services/auth_service.dart';
import '../../widgets/ConfirmationScreen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/password_input_field.dart'; // El widget de contraseña con ícono de ojo

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _PantallaRegistroState createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmarPasswordController =
      TextEditingController();

  String? tipoUsuario;
  List<String> tiposUsuario = ['Cliente', 'Proveedor'];

  bool cumpleMayuscula = false;
  bool cumpleNumero = false;
  bool cumpleSimbolo = false;
  bool cumpleLongitud = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FocusNode _nombreFocusNode = FocusNode();
  final FocusNode _apellidosFocusNode = FocusNode();
  final FocusNode _telefonoFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmarPasswordFocusNode = FocusNode();

  // Mostrar dialogo flotante usando el widget reutilizable
  void mostrarDialogo(String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConfirmationScreen(
            mensaje: mensaje,
            onButtonPressed: () {
              Navigator.pop(context); // Cierra el diálogo
              Navigator.pop(context); // Redirige al login
            },
          ),
        );
      },
    );
  }

  // Función para registrar al usuario utilizando AuthService
  Future<void> registrar() async {
    if (_formKey.currentState!.validate()) {
      String? mensaje = await _authService.registrarUsuario(
        nombreController.text,
        apellidosController.text,
        telefonoController.text,
        emailController.text,
        passwordController.text,
        tipoUsuario!,
      );

      mostrarDialogo(mensaje ?? 'Error desconocido.');
    }
  }

  // Función para validar la contraseña y actualizar las condiciones
  void validarPassword(String password) {
    setState(() {
      cumpleMayuscula = password.contains(RegExp(r'[A-Z]'));
      cumpleNumero = password.contains(RegExp(r'[0-9]'));
      cumpleSimbolo = password.contains(RegExp(r'[!@#\$%^&*()_\-+=<>?{}.,~]'));
      cumpleLongitud = password.length >= 8;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF438ef9),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: -50,
              top: -30,
              child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  "lib/assets/images/element_illustration.png",
                  width: MediaQuery.of(context).size.width * 0.8,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Regístrate en tu cuenta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30.0)),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDropdown(
                              label: 'Tipo de Usuario (Obligatorio)',
                              value: tipoUsuario,
                              items: tiposUsuario,
                              onChanged: (value) {
                                setState(() {
                                  tipoUsuario = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Selecciona un tipo de usuario.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Campo Nombre
                            CustomInputField(
                              controller: nombreController,
                              labelText: 'Nombre (Obligatorio)',
                              hintText: 'Ingresa tu nombre',
                              focusNode: _nombreFocusNode,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                                  return 'Por favor, ingresa un nombre válido.';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_apellidosFocusNode);
                              },
                            ),

                            const SizedBox(height: 20),

                            // Campo Apellidos
                            CustomInputField(
                              controller: apellidosController,
                              labelText: 'Apellidos (Obligatorio)',
                              hintText: 'Ingresa tus apellidos',
                              focusNode: _apellidosFocusNode,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                                  return 'Por favor, ingresa apellidos válidos.';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_telefonoFocusNode);
                              },
                            ),

                            const SizedBox(height: 20),

                            // Campo Teléfono
                            CustomInputField(
                              controller: telefonoController,
                              labelText: 'Número de Teléfono (Obligatorio)',
                              hintText: 'Ingresa tu número de teléfono',
                              keyboardType: TextInputType.phone,
                              focusNode: _telefonoFocusNode,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null ||
                                    value.length != 9 ||
                                    !RegExp(r'^\d{9}$').hasMatch(value)) {
                                  return 'Por favor, ingresa un número de teléfono válido.';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_emailFocusNode);
                              },
                            ),

                            const SizedBox(height: 20),

                            // Campo Correo Electrónico
                            CustomInputField(
                              controller: emailController,
                              labelText: 'Correo Electrónico (Obligatorio)',
                              hintText: 'Ingresa tu correo electrónico',
                              keyboardType: TextInputType.emailAddress,
                              focusNode: _emailFocusNode,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || !value.contains('@')) {
                                  return 'Por favor, ingresa un correo electrónico válido.';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_passwordFocusNode);
                              },
                            ),

                            const SizedBox(height: 20),

                            // Campo Contraseña con validaciones y ícono de ojo
                            PasswordInputField(
                              controller: passwordController,
                              focusNode: _passwordFocusNode,
                              labelText: 'Contraseña (Obligatorio)',
                              hintText: 'Ingresa tu contraseña',
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_confirmarPasswordFocusNode);
                              },
                              onChanged: validarPassword,
                              validator: (value) {
                                if (value == null ||
                                    !cumpleLongitud ||
                                    !cumpleMayuscula ||
                                    !cumpleNumero ||
                                    !cumpleSimbolo) {
                                  return 'La contraseña no cumple con los requisitos.';
                                }
                                return null;
                              },
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '• Al menos una mayúscula',
                                  style: TextStyle(
                                      color: cumpleMayuscula
                                          ? Colors.green
                                          : Colors.red),
                                ),
                                Text(
                                  '• Al menos un número',
                                  style: TextStyle(
                                      color: cumpleNumero
                                          ? Colors.green
                                          : Colors.red),
                                ),
                                Text(
                                  '• Al menos un símbolo',
                                  style: TextStyle(
                                      color: cumpleSimbolo
                                          ? Colors.green
                                          : Colors.red),
                                ),
                                Text(
                                  '• Mínimo 8 caracteres',
                                  style: TextStyle(
                                      color: cumpleLongitud
                                          ? Colors.green
                                          : Colors.red),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Confirmar Contraseña
                            PasswordInputField(
                              controller: confirmarPasswordController,
                              focusNode: _confirmarPasswordFocusNode,
                              labelText: 'Confirmar Contraseña (Obligatorio)',
                              hintText: 'Confirma tu contraseña',
                              textInputAction: TextInputAction.done,
                              validator: (value) {
                                if (value != passwordController.text) {
                                  return 'Las contraseñas no coinciden.';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 40),

                            // Botón de registro
                            SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                text: "Registrar",
                                type: ButtonType.PRIMARY,
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    registrar();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
