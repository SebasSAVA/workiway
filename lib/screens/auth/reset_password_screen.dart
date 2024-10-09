import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workiway/widgets/custom_button.dart'; // Suponiendo que tienes este widget

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? errorMessage; // Para mostrar errores

  // Función para enviar el correo de restablecimiento de contraseña
  Future<void> sendPasswordResetEmail() async {
    setState(() {
      errorMessage = null;
    });

    try {
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());
      setState(() {
        errorMessage = 'Correo de restablecimiento enviado. Revisa tu bandeja.';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = _traducirErrorFirebase(e.code);
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
      default:
        return 'Ocurrió un error desconocido. Inténtalo de nuevo.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF438ef9),
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
                    'Restablecer Contraseña',
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
                          Text(
                            'Introduce tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                            style: TextStyle(
                                fontSize: 16.0, color: Colors.black87),
                          ),
                          SizedBox(height: 20),

                          // Campo de correo electrónico
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Correo electrónico',
                              hintText: 'Introduce tu correo',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),

                          // Mostrar mensaje de error o confirmación
                          if (errorMessage != null) ...[
                            SizedBox(height: 20),
                            Text(
                              errorMessage!,
                              style: TextStyle(
                                color: errorMessage!.contains('enviado')
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 14.0,
                              ),
                            ),
                          ],

                          SizedBox(height: 40.0),

                          // Botón para enviar el correo de restablecimiento
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: "Enviar enlace de restablecimiento",
                              type: ButtonType.PRIMARY,
                              onPressed: sendPasswordResetEmail,
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
