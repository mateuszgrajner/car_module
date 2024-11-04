import 'package:flutter/material.dart';
import 'chart_widget.dart';

class EngineTempScreen extends StatelessWidget {
  const EngineTempScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChartWidget(
      title: 'Temperatura Silnika',
      lineColor: Color.fromARGB(255, 237, 100, 100), // Czerwona linia
      maxY: 160,
      yAxisLabel: '°C',
    );
  }
}
