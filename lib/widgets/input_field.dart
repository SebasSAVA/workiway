import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final String hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Function(String)?
      onChanged; // Agregar este parámetro para admitir onChanged

  const InputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.hintText = '',
    this.keyboardType,
    this.validator,
    this.onChanged, // Asegúrate de recibir onChanged en el constructor
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
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          validator: validator,
          onChanged: onChanged, // Aquí pasas onChanged al TextFormField
        ),
      ],
    );
  }
}
