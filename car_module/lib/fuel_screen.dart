import 'package:flutter/material.dart';
import 'chart_widget.dart';
import 'dart:async';
import 'package:car_module/database_helper.dart';
import 'dart:math';

class FuelConsumptionScreen extends StatefulWidget {
  const FuelConsumptionScreen({super.key});

  @override
  _FuelConsumptionScreenState createState() => _FuelConsumptionScreenState();
}

class _FuelConsumptionScreenState extends State<FuelConsumptionScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCollectingData();
  }

  void _startCollectingData() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      // Symulujemy wartość spalania (w rzeczywistości tutaj będzie pobierana rzeczywista wartość)
      final currentFuelConsumption = Random().nextDouble() * 20; // Losowa wartość spalania w zakresie 0-20

      // Zapisz dane do bazy
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertLiveDataLog(
        fuelConsumption: currentFuelConsumption,
        temperature: null, // Możemy ustawić na null, ponieważ skupiamy się na spalaniu
        speed: null, // Możemy ustawić na null, ponieważ skupiamy się na spalaniu
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
      title: 'Spalanie',
      lineColor: Color.fromARGB(255, 204, 103, 196),
      maxY: 20,
      yAxisLabel: 'Litry',
    );
  }
}
