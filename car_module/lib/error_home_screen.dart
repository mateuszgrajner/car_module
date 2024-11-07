import 'package:flutter/material.dart';
import 'app_bar_custom.dart';
import 'white_container.dart';
import 'loading_dialog.dart';
import 'dart:math';

class ErrorHomeScreen extends StatefulWidget {
  final Color color;

  const ErrorHomeScreen({super.key, required this.color});

  @override
  _ErrorHomeScreenState createState() => _ErrorHomeScreenState();
}

class _ErrorHomeScreenState extends State<ErrorHomeScreen> {
  List<Map<String, String>> errorCodes = [];
  bool isDeleted = false;

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

  Future<void> _showLoadingDialog(String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: message),
    );

    await Future.delayed(const Duration(seconds: 2));

    Navigator.of(context).pop(); // Zamknięcie dialogu po odczekaniu
  }

  void _deleteErrors() {
    setState(() {
      errorCodes.clear();
      isDeleted = true;
    });
  }

  void _handleButtonPress() async {
    if (errorCodes.isEmpty) {
      await _showLoadingDialog('Trwa skanowanie...');
      generateRandomErrors();
      setState(() {
        isDeleted = false;
      });
    } else {
      await _showLoadingDialog('Usuwanie błędów...');
      _deleteErrors();
    }
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
                child: errorCodes.isEmpty
                    ? Center(
                        child: Text(
                          isDeleted ? 'Brak błędów' : 'Kliknij odczyt aby rozpocząć skanowanie',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
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
                      onPressed: _handleButtonPress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: errorCodes.isEmpty ? Colors.green : Colors.yellow,
                        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                      ),
                      child: Text(
                        errorCodes.isEmpty ? 'Odczyt' : 'Kasowanie',
                        style: const TextStyle(color: Colors.black),
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
