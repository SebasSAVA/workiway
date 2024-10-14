import 'package:flutter/material.dart';

class ProfileOptionsList extends StatelessWidget {
  final List<Widget> options;

  const ProfileOptionsList({
    Key? key,
    required this.options,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white, // Si quieres que el fondo sea blanco
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: options,
      ),
    );
  }
}
