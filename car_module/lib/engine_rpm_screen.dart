import 'package:flutter/material.dart';
import 'chart_widget.dart';

class EngineRpmScreen extends StatelessWidget {
  const EngineRpmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChartWidget(
      title: 'Obroty Silnika',
      lineColor: Color.fromARGB(255, 81, 184, 120),
      maxY: 10000,
      yAxisLabel: 'RPM',
    );
  }
}