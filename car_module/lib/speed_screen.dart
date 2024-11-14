import 'package:flutter/material.dart';
import 'chart_widget.dart';
import 'dart:async';
import 'package:car_module/database_helper.dart';
import 'dart:math';

class VehicleSpeedScreen extends StatefulWidget {
  const VehicleSpeedScreen({super.key});

  @override
  _VehicleSpeedScreenState createState() => _VehicleSpeedScreenState();
}

class _VehicleSpeedScreenState extends State<VehicleSpeedScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCollectingData();
  }

  void _startCollectingData() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      // Symulujemy wartość prędkości (w rzeczywistości tutaj będzie pobierana rzeczywista wartość)
      final currentSpeed = Random().nextDouble() * 240; // Losowa wartość prędkości w zakresie 0-240 km/h

      // Zapisz dane do bazy
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertLiveDataLog(
        speed: currentSpeed,
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
      title: 'Prędkość Pojazdu',
      lineColor: Color.fromARGB(255, 63, 167, 153),
      maxY: 240,
      yAxisLabel: 'km/h',
    );
  }
}
