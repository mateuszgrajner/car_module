import 'package:flutter/material.dart';
import '../widgets/chart_widget.dart';
import '../logic/live_data_service.dart';

class VehicleSpeedScreen extends StatelessWidget {
  final LiveDataService liveDataService;

  const VehicleSpeedScreen({
    super.key,
    required this.liveDataService,
  });

  @override
  Widget build(BuildContext context) {
    return ChartWidget(
      title: 'Prędkość Pojazdu',
      lineColor: const Color.fromARGB(255, 63, 167, 153),
      maxY: 240,
      yAxisLabel: 'km/h',
      dataStream: liveDataService.speedStream, // Przekazujemy strumień prędkości
    );
  }
}
