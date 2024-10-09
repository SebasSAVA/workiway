import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart'; // Asegúrate de importar el CustomButton

class ConfirmationScreen extends StatelessWidget {
  final String mensaje;
  final IconData icono;
  final VoidCallback onButtonPressed;

  const ConfirmationScreen({
    Key? key,
    required this.mensaje,
    this.icono = Icons.email,
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(16.0),
        padding: EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              mensaje,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            CustomButton(
              text: 'Aceptar',
              onPressed: onButtonPressed,
              type: ButtonType.PRIMARY, // Botón con estilo primario
            ),
          ],
        ),
      ),
    );
  }
}
