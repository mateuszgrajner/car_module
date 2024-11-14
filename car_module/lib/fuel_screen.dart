import 'package:flutter/material.dart';
import 'chart_widget.dart';
import 'live_data_service.dart';

class FuelConsumptionScreen extends StatelessWidget {
  final LiveDataService liveDataService;

  const FuelConsumptionScreen({
    super.key,
    required this.liveDataService,
  });

  @override
  Widget build(BuildContext context) {
    return ChartWidget(
      title: 'Spalanie',
      lineColor: const Color.fromARGB(255, 204, 103, 196),
      maxY: 50, // Zaktualizowane maksymalne spalanie do 50 litrów
      yAxisLabel: 'Litry',
      dataStream: liveDataService.fuelConsumptionStream, // Przekazujemy strumień danych
    );
  }
}
