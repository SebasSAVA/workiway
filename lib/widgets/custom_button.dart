import 'package:flutter/material.dart';

enum ButtonType { PRIMARY, OUTLINE }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;

  const CustomButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.type = ButtonType.PRIMARY});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            type == ButtonType.PRIMARY ? const Color(0xFF438ef9) : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: const BorderSide(
              color: Color(0xFF438ef9),
              width: 2), // Borde azul para el botón OUTLINE
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          color: type == ButtonType.PRIMARY
              ? Colors.white
              : const Color(0xFF438ef9), // Color de texto según el botón
        ),
      ),
    );
  }
}
