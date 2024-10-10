import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required String? Function(dynamic value) validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value != null && value!.isNotEmpty
              ? value
              : null, // Verifica si el valor no es nulo y no está vacío
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            fillColor: Colors.grey[200],
            filled: true,
          ),
          icon: const Icon(Icons.arrow_drop_down),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
