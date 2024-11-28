import 'package:flutter/material.dart';
import '../core/app_bar_custom.dart';
import '../core/white_container.dart';
import '../core/reading_widget_card.dart';
import 'package:car_module/services/database_helper.dart';

class ReadingsLogScreen extends StatefulWidget {
  const ReadingsLogScreen({super.key});

  @override
  _ReadingsLogScreenState createState() => _ReadingsLogScreenState();
}

class _ReadingsLogScreenState extends State<ReadingsLogScreen> {
  List<Map<String, dynamic>> readingsLog = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReadingsLog();
  }

  Future<void> _loadReadingsLog() async {
  setState(() {
    isLoading = true;
  });

  final dbHelper = DatabaseHelper.instance;
  final allReadings = await dbHelper.getAllReadingsWithErrors();

  setState(() {
    readingsLog = allReadings.map((reading) {
      // Formatowanie godziny i minut
      final timeParts = reading['time'].split(':');
      final hours = timeParts[0].padLeft(2, '0');
      final minutes = timeParts[1].padLeft(2, '0');
      final formattedTime = '$hours:$minutes';

      return {
        ...reading,
        'time': formattedTime,
      };
    }).toList();
    isLoading = false;
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
            const AppBarCustom(title: 'Dziennik odczytów'),
            const SizedBox(height: 16.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : readingsLog.isEmpty
                        ? const Center(
                            child: Text(
                              'Brak zapisanych odczytów',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: readingsLog.length,
                            itemBuilder: (context, index) {
                              final reading = readingsLog[index];
                              return ReadingCardWidget(
                                date: reading['date'],
                                time: reading['time'],
                                errorCount: reading['errorCount'],
                                errorDetails: List<Map<String, String>>.from(
                                  reading['errors'].map((error) {
                                    return {
                                      'code': error['code']?.toString() ?? '',
                                      'description': error['description']?.toString() ?? '',
                                    };
                                  }),
                                ),
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
