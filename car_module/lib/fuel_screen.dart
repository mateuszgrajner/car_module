import 'package:flutter/material.dart';
import 'chart_widget.dart';

class FuelConsumptionScreen extends StatelessWidget {
  const FuelConsumptionScreen({super.key});

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
