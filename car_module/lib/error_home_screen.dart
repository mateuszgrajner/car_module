import 'package:flutter/material.dart';
import 'app_bar_custom.dart';
import 'white_container.dart';
import 'loading_dialog.dart';
import 'package:car_module/demo_obd_connection.dart';
import 'package:car_module/error_code_model.dart';
import 'package:car_module/database_helper.dart';

class ErrorHomeScreen extends StatefulWidget {
  final Color color;

  const ErrorHomeScreen({super.key, required this.color});

  @override
  _ErrorHomeScreenState createState() => _ErrorHomeScreenState();
}

class _ErrorHomeScreenState extends State<ErrorHomeScreen> {
  List<ErrorCode> errorCodes = [];
  bool isDeleted = false;
  final DemoObdConnection demoConnection = DemoObdConnection();

  Future<void> _readErrors() async {
    try {
      print('Rozpoczynam odczyt błędów...');
      await demoConnection.connect();
      final rawErrors = await demoConnection.sendCommand('03');
      print('Otrzymane surowe błędy: $rawErrors');

      if (rawErrors == 'NO DATA') {
        setState(() {
          errorCodes = [];
        });
        return;
      }

      final codes = rawErrors.split(',').map((e) => e.trim().toUpperCase()).toList();
      final dbHelper = DatabaseHelper.instance;

      final allErrorCodes = await dbHelper.getAllErrorCodes();
      final errorCodeList = allErrorCodes.map((e) => e.code.toUpperCase()).toList();

      final mappedErrors = codes.map((code) {
        if (errorCodeList.contains(code)) {
          return allErrorCodes.firstWhere((e) => e.code == code);
        } else {
          return ErrorCode(
            id: 0,
            code: code,
            description: 'Nieznany błąd ECU',
          );
        }
      }).toList();

      setState(() {
        errorCodes = mappedErrors;
      });

      // Zapisz odczyt błędów w bazie danych
      final now = DateTime.now();
      await dbHelper.insertReading(
        '${now.day}.${now.month}.${now.year}',
        '${now.hour}:${now.minute}',
        errorCodes,
      );
      print('Błędy zostały zapisane w bazie.');
    } catch (e) {
      print('Błąd podczas odczytu błędów: $e');
    } finally {
      await demoConnection.disconnect();
    }
  }

  Future<void> _clearErrors() async {
    try {
      print('Rozpoczynam kasowanie błędów...');
      await demoConnection.connect();
      await demoConnection.sendCommand('04');
      setState(() {
        errorCodes = [];
        isDeleted = true;
      });
      print('Błędy zostały skasowane.');
    } catch (e) {
      print('Błąd podczas kasowania błędów: $e');
    } finally {
      await demoConnection.disconnect();
    }
  }

  Future<void> _handleButtonPress() async {
    if (errorCodes.isEmpty) {
      await _showLoadingDialog('Trwa skanowanie...');
      await _readErrors();
    } else {
      await _showLoadingDialog('Usuwanie błędów...');
      await _clearErrors();
    }
  }

  Future<void> _showLoadingDialog(String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: message),
    );

    await Future.delayed(const Duration(seconds: 2));
    Navigator.of(context).pop();
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
                          isDeleted ? 'Brak błędów' : 'Kliknij odczyt, aby rozpocząć skanowanie',
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
                        backgroundColor:
                            errorCodes.isEmpty ? Colors.green : Colors.yellow,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32.0, vertical: 16.0),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32.0, vertical: 16.0),
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
