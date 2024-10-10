import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart'; // Asegúrate de importar el CustomButton

class ConfirmationScreen extends StatelessWidget {
  final String mensaje;
  final IconData icono;
  final VoidCallback onButtonPressed;

  const ConfirmationScreen({
    super.key,
    required this.mensaje,
    this.icono = Icons.email,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            Text(
              mensaje,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
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
