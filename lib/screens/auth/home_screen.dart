import 'package:flutter/material.dart';
import 'package:workiway/utils/constants.dart';
import 'package:workiway/widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.primaryColor,
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Image.asset(
                "lib/assets/images/workiway_illustration.png"), // Imagen de Workiway
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30.0),
                  topLeft: Radius.circular(30.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .start, // Cambia para alinear texto a la izquierda
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "¡Bienvenido a Workiway!",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Esta es la primera versión de nuestra app de servicios. Por favor inicia sesión o crea una cuenta abajo.",
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double
                        .infinity, // Hace que el botón ocupe todo el ancho
                    child: CustomButton(
                      text: "Iniciar Sesión",
                      type: ButtonType.OUTLINE,
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double
                        .infinity, // Hace que el botón ocupe todo el ancho
                    child: CustomButton(
                      text: "Crear una Cuenta",
                      type: ButtonType.PRIMARY,
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
