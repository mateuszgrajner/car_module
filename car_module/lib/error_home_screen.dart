import 'package:flutter/material.dart';
import 'app_bar_custom.dart';
import 'white_container.dart';
import 'dart:math';

class ErrorHomeScreen extends StatefulWidget {
  final Color color;

  const ErrorHomeScreen({super.key, required this.color});

  @override
  _ErrorHomeScreenState createState() => _ErrorHomeScreenState();
}

class _ErrorHomeScreenState extends State<ErrorHomeScreen> {
  List<Map<String, String>> errorCodes = [];

  void generateRandomErrors() {
    final List<Map<String, String>> sampleErrors = [
      {'code': 'P0301', 'description': 'Cylinder 1 - misfire detected'},
      {'code': 'P0123', 'description': 'Throttle/Pedal Position Sensor/Switch A Circuit High'},
      {'code': 'P0169', 'description': 'Incorrect Fuel Composition'},
      {'code': 'O5523', 'description': 'Steering Column Position Sensor Malfunction'},
    ];

    final random = Random();
    setState(() {
      errorCodes = List.generate(4, (index) => sampleErrors[random.nextInt(sampleErrors.length)]);
    });
  }

  @override
  Widget build(BuildContext context) {
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
            const AppBarCustom(title: 'Odczyt błędów'),
            const SizedBox(height: 16.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: ListView.builder(
                  itemCount: errorCodes.length,
                  itemBuilder: (context, index) {
                    final error = errorCodes[index];
                    return Card(
                      color: const Color.fromARGB(255, 153, 45, 163),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              error['code'] ?? '',
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              error['description'] ?? '',
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: WhiteContainer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        generateRandomErrors();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                      ),
                      child: const Text(
                        'Odczyt',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                      ),
                      child: const Text(
                        'Wróć',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
