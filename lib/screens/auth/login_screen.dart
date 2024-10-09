import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workiway/services/auth_service.dart';
import 'package:workiway/widgets/custom_button.dart';
import 'package:workiway/widgets/custom_input_field.dart'; // El nuevo widget

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Añadimos FocusNodes para cambiar entre campos automáticamente
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? errorMessage; // Para almacenar el mensaje de error
  String?
      resetPasswordMessage; // Para mensajes relacionados con restablecimiento de contraseña

  // Función para iniciar sesión y verificar el correo
  Future<void> iniciarSesion(BuildContext context) async {
    setState(() {
      errorMessage = null; // Limpiar el mensaje de error al iniciar sesión
      resetPasswordMessage =
          null; // Limpiar el mensaje de restablecimiento de contraseña
    });
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;

      // Verificar si el correo ha sido verificado
      if (user != null && !user.emailVerified) {
        setState(() {
          errorMessage = 'Debes verificar tu correo antes de iniciar sesión.';
        });
        await _auth.signOut();
      } else {
        await AuthService().actualizarEmailVerificado(user!);
        // Redirigir a la siguiente pantalla, si todo está bien
        Navigator.pushNamed(context, '/dashboard'); // Cambia según tu ruta
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage =
            _traducirErrorFirebase(e.code); // Traduce el mensaje de error
      });
    }
  }

  // Función para enviar correo de restablecimiento de contraseña
  Future<void> restablecerContrasena() async {
    setState(() {
      errorMessage = null; // Limpiar mensajes de error anteriores
      resetPasswordMessage =
          null; // Limpiar mensajes anteriores de restablecimiento
    });

    try {
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());
      setState(() {
        resetPasswordMessage =
            'Correo de restablecimiento enviado. Revisa tu bandeja de entrada.';
      });
    } catch (e) {
      setState(() {
        errorMessage =
            'Ocurrió un error al intentar enviar el correo de restablecimiento.';
      });
    }
  }

  // Función para traducir los errores comunes de FirebaseAuth al español
  String _traducirErrorFirebase(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'user-not-found':
        return 'No hay ningún usuario registrado con este correo.';
      case 'wrong-password':
        return 'La contraseña es incorrecta.';
      case 'user-disabled':
        return 'Este usuario ha sido deshabilitado.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Inténtalo de nuevo más tarde.';
      default:
        return 'Ocurrió un error desconocido. Inténtalo de nuevo.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF438ef9), // Color principal
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: -50,
              top: -30,
              child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  "lib/assets/images/element_illustration.png", // Imagen de fondo
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
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Inicia sesión en tu cuenta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 50),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30.0)),
                    ),
                    padding: EdgeInsets.all(24.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),

                          // Campo de correo electrónico con teclado personalizado
                          CustomInputField(
                            controller: emailController,
                            focusNode: _emailFocusNode,
                            keyboardType:
                                TextInputType.emailAddress, // Teclado con '@'
                            textInputAction:
                                TextInputAction.next, // Botón "Siguiente"
                            labelText: 'Correo electrónico',
                            hintText: 'Ingrese su correo',
                            onFieldSubmitted: (_) {
                              // Cambia el foco al siguiente campo (Contraseña)
                              FocusScope.of(context)
                                  .requestFocus(_passwordFocusNode);
                            },
                          ),

                          SizedBox(height: 20.0),

                          // Campo de contraseña
                          CustomInputField(
                            controller: passwordController,
                            focusNode: _passwordFocusNode,
                            obscureText: true,
                            textInputAction:
                                TextInputAction.done, // Botón "Hecho"
                            labelText: 'Contraseña',
                            hintText: 'Ingrese su contraseña',
                          ),

                          // Mostrar mensaje de error en caso de haber alguno
                          if (errorMessage != null) ...[
                            SizedBox(height: 20.0),
                            Text(
                              errorMessage!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14.0,
                              ),
                            ),
                          ],

                          // Mostrar mensaje de éxito en restablecimiento de contraseña
                          if (resetPasswordMessage != null) ...[
                            SizedBox(height: 20.0),
                            Text(
                              resetPasswordMessage!,
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 14.0,
                              ),
                            ),
                          ],

                          SizedBox(height: 20.0),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context,
                                    '/reset-password'); // Redirige a la nueva pantalla
                              },
                              child: Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  color: Color(0xFF438ef9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 40.0),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: "Iniciar sesión",
                              type: ButtonType.PRIMARY,
                              onPressed: () {
                                iniciarSesion(
                                    context); // Llama a la función de inicio de sesión
                              },
                            ),
                          ),
                        ],
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
