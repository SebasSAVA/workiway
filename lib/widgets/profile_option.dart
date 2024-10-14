import 'package:flutter/material.dart';

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const ProfileOption({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Hace que la animación sea visible
      child: InkWell(
        onTap: onTap,
        splashColor: Theme.of(context).primaryColor.withOpacity(0.2),
        child: ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            child: Icon(icon, color: Colors.grey[700]),
          ),
          title: Text(text),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[600]),
        ),
      ),
    );
  }
}
