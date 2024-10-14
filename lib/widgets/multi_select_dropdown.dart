// multi_select_dropdown.dart
import 'package:flutter/material.dart';

class MultiSelectDropdown extends StatefulWidget {
  final String labelText;
  final List<String> items;
  final List<String> selectedItems;
  final ValueChanged<List<String>> onChanged;

  const MultiSelectDropdown({
    Key? key,
    required this.labelText,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
  }) : super(key: key);

  @override
  _MultiSelectDropdownState createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.labelText,
          border: const OutlineInputBorder(),
        ),
        child: Wrap(
          spacing: 8.0,
          children: widget.items.map((item) {
            final isSelected = widget.selectedItems.contains(item);
            return ChoiceChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    if (!widget.selectedItems.contains(item)) {
                      widget.selectedItems.add(item);
                    }
                  } else {
                    widget.selectedItems.remove(item);
                  }
                  widget.onChanged(widget.selectedItems);
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
