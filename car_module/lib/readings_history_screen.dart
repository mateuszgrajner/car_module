import 'package:flutter/material.dart';
import 'app_bar_custom.dart';
import 'white_container.dart';
import 'reading_widget_card.dart';

class ReadingsLogScreen extends StatelessWidget {
  const ReadingsLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> readingsLog = [
      {
        'date': '29.10.2024',
        'time': '14:30',
        'errorCount': 3,
        'errors': [
          {'code': 'P0301', 'description': 'Cylinder 1 - misfire detected'},
          {'code': 'P0123', 'description': 'Throttle Position Sensor High'},
          {'code': 'O5523', 'description': 'Steering Column Position Sensor Malfunction'},
          {'code': 'O5523', 'description': 'Steering Column Position Sensor Malfunction'},
          {'code': 'O5523', 'description': 'Steering Column Position Sensor Malfunction'},
          {'code': 'O5523', 'description': 'Steering Column Position Sensor Malfunction'},
        ],
      },
      {
        'date': '11.10.2024',
        'time': '09:15',
        'errorCount': 2,
        'errors': [
          {'code': 'P0456', 'description': 'Evaporative Emission System Leak Detected'},
          {'code': 'P0507', 'description': 'Idle Control System RPM Higher Than Expected'},
        ],
      },
      {
        'date': '11.10.2024',
        'time': '09:15',
        'errorCount': 2,
        'errors': [
          {'code': 'P0456', 'description': 'Evaporative Emission System Leak Detected'},
          {'code': 'P0507', 'description': 'Idle Control System RPM Higher Than Expected'},
        ],
      },
      {
        'date': '11.10.2024',
        'time': '09:15',
        'errorCount': 2,
        'errors': [
          {'code': 'P0456', 'description': 'Evaporative Emission System Leak Detected'},
          {'code': 'P0507', 'description': 'Idle Control System RPM Higher Than Expected'},
        ],
      },
    ];


    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 28, 26, 31),
              Color.fromARGB(255, 49, 49, 49),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppBarCustom(title: 'Dziennik odczytów'),
            const SizedBox(height: 16.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: ListView.builder(
                  itemCount: readingsLog.length,
                  itemBuilder: (context, index) {
                    final reading = readingsLog[index];
                    return ReadingCardWidget(
                      date: reading['date'],
                      time: reading['time'],
                      errorCount: reading['errorCount'],
                      errorDetails: List<Map<String, String>>.from(reading['errors']),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: WhiteContainer(
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 150.0,
                        vertical: 16.0,
                      ),
                    ),
                    child: const Text(
                      'Powrót',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
