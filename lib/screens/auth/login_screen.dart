import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workiway/services/auth_service.dart';
import 'package:workiway/widgets/custom_button.dart';
import 'package:workiway/widgets/custom_input_field.dart';
import 'package:workiway/widgets/customer_bottom_navigation.dart';
import 'package:workiway/widgets/provider_bottom_navigation.dart';
import 'package:workiway/widgets/password_input_field.dart'; // Importa el widget de contraseña
import 'package:workiway/services/error_handler.dart'; // Importa el archivo que maneja los errores

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  String? errorMessage;
  String? resetPasswordMessage;

  // Función para iniciar sesión y verificar el correo
  Future<void> iniciarSesion(BuildContext context) async {
    setState(() {
      errorMessage = null;
      resetPasswordMessage = null;
    });

    try {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        setState(() {
          errorMessage = 'Por favor, ingresa un correo y una contraseña.';
        });
        return;
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        setState(() {
          errorMessage = 'Debes verificar tu correo antes de iniciar sesión.';
        });
        await _auth.signOut();
      } else {
        await _authService.actualizarEmailVerificado(user!);

        bool esCliente = await _authService.esCliente(user.uid);

        if (esCliente) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerBottomNavigation(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderBottomNavigation(),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = ErrorHandler.traducirErrorFirebase(e.code);
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error inesperado: ${e.toString()}';
      });
    }
  }

  // Función para enviar correo de restablecimiento de contraseña
  Future<void> restablecerContrasena() async {
    setState(() {
      errorMessage = null;
      resetPasswordMessage = null;
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
                    'Inicia sesión en tu cuenta',
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Campo de correo electrónico
                          CustomInputField(
                            controller: emailController,
                            focusNode: _emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            labelText: 'Correo electrónico',
                            hintText: 'Ingrese su correo',
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_passwordFocusNode);
                            },
                          ),

                          const SizedBox(height: 20.0),

                          // Campo de contraseña con el widget PasswordInputField
                          PasswordInputField(
                            controller: passwordController,
                            focusNode: _passwordFocusNode,
                            labelText: 'Contraseña',
                            hintText: 'Ingrese su contraseña',
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              iniciarSesion(context);
                            },
                          ),

                          if (errorMessage != null) ...[
                            const SizedBox(height: 20.0),
                            Text(
                              errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14.0,
                              ),
                            ),
                          ],

                          if (resetPasswordMessage != null) ...[
                            const SizedBox(height: 20.0),
                            Text(
                              resetPasswordMessage!,
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 14.0,
                              ),
                            ),
                          ],

                          const SizedBox(height: 20.0),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/reset-password');
                              },
                              child: const Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  color: Color(0xFF438ef9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40.0),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: "Iniciar sesión",
                              type: ButtonType.PRIMARY,
                              onPressed: () {
                                iniciarSesion(context);
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
