import 'package:flutter/material.dart';
import 'package:workiway/widgets/custom_button.dart';

class ServiceAvailabilityDialog extends StatefulWidget {
  final Function(Map<String, Map<String, String>>) onAvailabilitySelected;

  const ServiceAvailabilityDialog(
      {Key? key, required this.onAvailabilitySelected})
      : super(key: key);

  @override
  _ServiceAvailabilityDialogState createState() =>
      _ServiceAvailabilityDialogState();
}

class _ServiceAvailabilityDialogState extends State<ServiceAvailabilityDialog> {
  Map<String, bool> selectedDays = {
    'Lunes': false,
    'Martes': false,
    'Miércoles': false,
    'Jueves': false,
    'Viernes': false,
    'Sábado': false,
    'Domingo': false,
  };

  Map<String, TimeOfDay?> startTimes = {
    'Lunes': null,
    'Martes': null,
    'Miércoles': null,
    'Jueves': null,
    'Viernes': null,
    'Sábado': null,
    'Domingo': null,
  };

  Map<String, TimeOfDay?> endTimes = {
    'Lunes': null,
    'Martes': null,
    'Miércoles': null,
    'Jueves': null,
    'Viernes': null,
    'Sábado': null,
    'Domingo': null,
  };

  Future<void> _selectTime(String day, bool isStart) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTimes[day] = picked;
        } else {
          if (startTimes[day] != null && startTimes[day]!.hour > picked.hour) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'El horario de fin debe ser mayor que el de inicio.',
                    style: TextStyle(color: Colors.red)),
              ),
            );
          } else {
            endTimes[day] = picked;
          }
        }
      });
    }
  }

  bool _isAnyDaySelectedWithTime() {
    return selectedDays.keys.any((day) =>
        selectedDays[day] == true &&
        startTimes[day] != null &&
        endTimes[day] != null);
  }

  void _saveAvailability() {
    Map<String, Map<String, String>> availability = {};
    selectedDays.forEach((day, isSelected) {
      if (isSelected && startTimes[day] != null && endTimes[day] != null) {
        availability[day] = {
          'start': startTimes[day]!.format(context),
          'end': endTimes[day]!.format(context),
        };
      }
    });
    widget.onAvailabilitySelected(
        availability); // Pasar la disponibilidad seleccionada al callback
    Navigator.of(context).pop(); // Cierra el diálogo
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selecciona los días y horas disponibles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: selectedDays.keys.map((day) {
                return Row(
                  children: [
                    Checkbox(
                      value: selectedDays[day],
                      onChanged: (bool? value) {
                        setState(() {
                          selectedDays[day] = value!;
                        });
                      },
                    ),
                    Expanded(child: Text(day)),
                    if (selectedDays[day] == true) ...[
                      TextButton(
                        onPressed: () => _selectTime(day, true),
                        child:
                            Text(startTimes[day]?.format(context) ?? 'Inicio'),
                      ),
                      TextButton(
                        onPressed: () => _selectTime(day, false),
                        child: Text(endTimes[day]?.format(context) ?? 'Fin'),
                      ),
                    ],
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (_isAnyDaySelectedWithTime()) ...[
              CustomButton(
                text: 'Guardar Disponibilidad',
                onPressed: _saveAvailability, // Llama a guardar disponibilidad
                type: ButtonType.PRIMARY,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
