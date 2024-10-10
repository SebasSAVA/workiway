import 'package:flutter/material.dart';

class PasswordInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String labelText;
  final String hintText;
  final TextInputAction textInputAction;
  final Function(String)? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final Function(String)? onChanged;

  const PasswordInputField({
    Key? key,
    required this.controller,
    this.focusNode,
    required this.labelText,
    required this.hintText,
    required this.textInputAction,
    this.onFieldSubmitted,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  _PasswordInputFieldState createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false; // Inicialmente, la contraseña está oculta
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: const TextStyle(fontSize: 16.0, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText:
              !_passwordVisible, // Controla visibilidad de la contraseña
          textInputAction: widget.textInputAction,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
          ),
          onFieldSubmitted: widget.onFieldSubmitted,
          validator: widget.validator,
          onChanged: widget.onChanged, // Añadir el soporte para onChanged
        ),
      ],
    );
  }
}
