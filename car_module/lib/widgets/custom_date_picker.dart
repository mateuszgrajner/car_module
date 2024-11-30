import 'package:flutter/material.dart';

class CustomDatePickerDialog extends StatefulWidget {
  final Function(DateTime startDate, DateTime endDate) onDateSelected;

  const CustomDatePickerDialog({super.key, required this.onDateSelected});

  @override
  _CustomDatePickerDialogState createState() => _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<CustomDatePickerDialog> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 218, 219, 223),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Wybierz datę',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16.0),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Data początkowa'),
              subtitle: _startDate != null
                  ? Text('${_startDate!.day}/${_startDate!.month}/${_startDate!.year}')
                  : const Text('Nie wybrano daty'),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _startDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 8.0),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Data końcowa'),
              subtitle: _endDate != null
                  ? Text('${_endDate!.day}/${_endDate!.month}/${_endDate!.year}')
                  : const Text('Nie wybrano daty'),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _endDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Anuluj',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (_startDate != null && _endDate != null) {
                      widget.onDateSelected(_startDate!, _endDate!);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
