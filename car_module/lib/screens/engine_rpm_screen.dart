import 'package:flutter/material.dart';
import '../services/chart_widget.dart';
import '../services/live_data_service.dart';

class EngineRpmScreen extends StatelessWidget {
  final LiveDataService liveDataService;

  const EngineRpmScreen({
    super.key,
    required this.liveDataService,
  });

  @override
  Widget build(BuildContext context) {
    return ChartWidget(
      title: 'Obroty Silnika',
      lineColor: const Color.fromARGB(255, 81, 184, 120),
      maxY: 10000,
      yAxisLabel: 'RPM',
      dataStream: liveDataService.rpmStream, // Przekazujemy strumień danych
    );
  }
}
