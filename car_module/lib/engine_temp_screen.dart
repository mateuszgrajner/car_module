import 'package:flutter/material.dart';
import 'chart_widget.dart';
import 'dart:async';
import 'package:car_module/database_helper.dart';
import 'dart:math';

class EngineTempScreen extends StatefulWidget {
  const EngineTempScreen({super.key});

  @override
  _EngineTempScreenState createState() => _EngineTempScreenState();
}

class _EngineTempScreenState extends State<EngineTempScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCollectingData();
  }

  void _startCollectingData() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      // Symulujemy wartość temperatury (w rzeczywistości tutaj będzie pobierana rzeczywista wartość)
      final currentTemperature = Random().nextDouble() * 160; // Losowa wartość temperatury w zakresie 0-160°C

      // Zapisz dane do bazy
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertLiveDataLog(
        temperature: currentTemperature,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const ChartWidget(
      title: 'Temperatura Silnika',
      lineColor: Color.fromARGB(255, 237, 100, 100),
      maxY: 160,
      yAxisLabel: '°C',
    );
  }
}
