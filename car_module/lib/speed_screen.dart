import 'package:flutter/material.dart';
import 'chart_widget.dart';

class VehicleSpeedScreen extends StatelessWidget {
  const VehicleSpeedScreen({super.key});

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