import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final String hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Function(String)? onChanged; // Soporte para onChanged
  final TextInputAction? textInputAction; // Soporte para TextInputAction
  final FocusNode? focusNode; // Soporte para FocusNode
  final Function(String)? onFieldSubmitted; // Soporte para onFieldSubmitted

  const CustomInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.hintText = '',
    this.keyboardType,
    this.validator,
    this.onChanged, // Asegúrate de recibir onChanged en el constructor
    this.textInputAction, // Para mover el foco o completar el formulario
    this.focusNode, // Para cambiar el foco de los campos
    this.onFieldSubmitted, // Para manejar la acción de enviar
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(fontSize: 16.0, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction, // Utiliza TextInputAction
          focusNode: focusNode, // Utiliza FocusNode
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          validator: validator,
          onChanged: onChanged, // Soporte para onChanged
          onFieldSubmitted: onFieldSubmitted, // Soporte para onFieldSubmitted
        ),
      ],
    );
  }
}
