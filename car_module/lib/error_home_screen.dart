import 'package:flutter/material.dart';
import 'app_bar_custom.dart';
import 'white_container.dart';
import 'loading_dialog.dart';
import 'dart:math';
import 'package:car_module/database_helper.dart';
import 'package:car_module/error_code_model.dart';

class ErrorHomeScreen extends StatefulWidget {
  final Color color;

  const ErrorHomeScreen({super.key, required this.color});

  @override
  _ErrorHomeScreenState createState() => _ErrorHomeScreenState();
}

class _ErrorHomeScreenState extends State<ErrorHomeScreen> {
  List<ErrorCode> errorCodes = [];
  bool isDeleted = false;

  Future<void> generateRandomErrors() async {
  final dbHelper = DatabaseHelper.instance;
  final errorCodeCount = await dbHelper.getErrorCodeCount();

  if (errorCodeCount == 0) {
    // Brak dostępnych kodów błędów w bazie danych
    setState(() {
      errorCodes = [];
    });
    return;
  }

  print('Pobieram wszystkie kody błędów...');
  // Pobierz wszystkie kody błędów
  final allErrorCodes = await dbHelper.getAllErrorCodes();
  print('Pobrane kody błędów: ${allErrorCodes.length}');

  // Generowanie losowych kodów błędów z bazy danych
  final random = Random();
  final selectedErrorCodes = List<ErrorCode>.generate(
    allErrorCodes.length < 4 ? allErrorCodes.length : 4,
    (index) => allErrorCodes[random.nextInt(allErrorCodes.length)],
  );

  setState(() {
    errorCodes = selectedErrorCodes;
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
    await generateRandomErrors();

    // Zapisz odczyt do bazy danych
    if (errorCodes.isNotEmpty) {
      final dbHelper = DatabaseHelper.instance;
      final now = DateTime.now();
      await dbHelper.insertReading(
        '${now.day}.${now.month}.${now.year}',
        '${now.hour}:${now.minute}',
        errorCodes,
      );
    }

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
                                    error.code,
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    error.description,
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
