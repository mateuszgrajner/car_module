import 'package:flutter/material.dart';
import 'chart_widget.dart';
import 'live_data_service.dart';

class EngineTempScreen extends StatelessWidget {
  final LiveDataService liveDataService;

  const EngineTempScreen({
    super.key,
    required this.liveDataService,
  });

  @override
  Widget build(BuildContext context) {
    return ChartWidget(
      title: 'Temperatura Silnika',
      lineColor: const Color.fromARGB(255, 237, 100, 100),
      maxY: 160,
      yAxisLabel: '°C',
      dataStream: liveDataService.temperatureStream, // Przekazujemy strumień danych
    );
  }
}
