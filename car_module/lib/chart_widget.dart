import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'app_bar_custom.dart';
import 'white_container.dart';

class ChartWidget extends StatefulWidget {
  final String title;
  final Color lineColor;
  final double maxY;
  final String yAxisLabel;

  const ChartWidget({
    super.key,
    required this.title,
    required this.lineColor,
    required this.maxY,
    required this.yAxisLabel,
  });

  @override
  _ChartWidgetState createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  List<FlSpot> chartData = [
    FlSpot(0, 5),
    FlSpot(5, 7),
    FlSpot(10, 6),
    FlSpot(15, 8),
    FlSpot(20, 9),
  ];

  Timer? _timer;
  double _time = 20;

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _time += 1;
        double newValue = (5 + Random().nextInt(widget.maxY.toInt() - 5)).toDouble();
        chartData.add(FlSpot(_time, newValue));

        if (chartData.length > 20) {
          chartData.removeAt(0);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 28, 26, 31),
              Color.fromARGB(255, 49, 49, 49),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppBarCustom(title: widget.title),
            const SizedBox(height: 16.0),
            // Wykres danych
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.white.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.white.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: 5,
                          getTitlesWidget: (value, _) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: widget.maxY / 8,
                          getTitlesWidget: (value, _) {
                            return Text(
                              '${value.toInt()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: Colors.white,
                      ),
                    ),
                    minX: _time - 20,
                    maxX: _time,
                    minY: 0,
                    maxY: widget.maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartData,
                        isCurved: false,
                        color: widget.lineColor,
                        barWidth: 3,
                        isStrokeCapRound: false,
                        dotData: FlDotData(
                          show: true,
                        ),
                        belowBarData: BarAreaData(
                          show: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Przycisk powrotu
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: WhiteContainer(
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 150.0,
                        vertical: 16.0,
                      ),
                    ),
                    child: const Text(
                      'Powrót',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
