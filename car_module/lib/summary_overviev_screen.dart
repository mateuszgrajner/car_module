import 'dart:async';
import 'package:flutter/material.dart';
import 'app_bar_custom.dart';
import 'white_container.dart';
import 'summary_card_widget.dart';
import 'custom_date_picker.dart';
import 'package:car_module/database_helper.dart';

class SummaryOverviewScreen extends StatefulWidget {
  const SummaryOverviewScreen({super.key});

  @override
  _SummaryOverviewScreenState createState() => _SummaryOverviewScreenState();
}

class _SummaryOverviewScreenState extends State<SummaryOverviewScreen> {
  String _selectedPeriod = 'Dzisiaj';
  Color _cardColor = const Color.fromARGB(255, 60, 172, 94);
  Map<String, String> _summaryData = {
    'Średnie spalanie': 'Ładowanie...',
    'Średnia temperatura': 'Ładowanie...',
    'Średnia prędkość': 'Ładowanie...',
  };

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _updateSummary(_selectedPeriod, _cardColor);
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateSummary(_selectedPeriod, _cardColor);
    });
  }

  Future<void> _updateSummary(String period, Color color) async {
    setState(() {
      _selectedPeriod = period;
      _cardColor = color;
    });

    String dbPeriod;
    switch (period) {
      case 'Dzisiaj':
        dbPeriod = 'today';
        break;
      case 'Ostatni tydzień':
        dbPeriod = 'week';
        break;
      case 'Ostatni miesiąc':
        dbPeriod = 'month';
        break;
      default:
        dbPeriod = 'today';
    }

    final dbHelper = DatabaseHelper.instance;
    final averageData = await dbHelper.getAverageLiveData(dbPeriod);
    print('Dane pobrane z bazy: $averageData');

    setState(() {
      _summaryData = {
        'Średnie spalanie': averageData['avg_fuel'] != null
            ? '${averageData['avg_fuel']!.toStringAsFixed(2)} L/100km'
            : 'Brak danych',
        'Średnia temperatura': averageData['avg_temperature'] != null
            ? '${averageData['avg_temperature']!.toStringAsFixed(1)} °C'
            : 'Brak danych',
        'Średnia prędkość': averageData['avg_speed'] != null
            ? '${averageData['avg_speed']!.toStringAsFixed(1)} km/h'
            : 'Brak danych',
      };
    });
  }

  void _selectCustomPeriod() {
    showDialog(
      context: context,
      builder: (context) => CustomDatePickerDialog(
        onDateSelected: (startDate, endDate) {
          setState(() {
            _selectedPeriod =
                '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}';
            _cardColor = const Color.fromARGB(255, 255, 105, 180); // Różowy kolor karty
            _summaryData = {
              'Średnie spalanie': 'Brak danych',
              'Średnia temperatura': 'Brak danych',
              'Średnia prędkość': 'Brak danych',
            };
          });
        },
      ),
    );
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
            const AppBarCustom(title: 'Podsumowanie okresowe'),
            const SizedBox(height: 16.0),
            // White container with period buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: WhiteContainer(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Wybierz okres',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Center(
                      child: Wrap(
                        spacing: 12.0,
                        runSpacing: 8.0,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildPeriodButton('Dzisiaj', Colors.green),
                          _buildPeriodButton('Ostatni tydzień', Colors.purple),
                          _buildPeriodButton('Ostatni miesiąc', Colors.blue),
                          _buildPeriodButton('Niestandardowe', Colors.pink, isCustom: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Summary card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SummaryCardWidget(
                title: _selectedPeriod,
                data: [
                  {
                    'label': 'Średnie spalanie',
                    'value': _summaryData['Średnie spalanie']!,
                    'icon': Icons.local_gas_station,
                  },
                  {
                    'label': 'Średnia temperatura',
                    'value': _summaryData['Średnia temperatura']!,
                    'icon': Icons.thermostat,
                  },
                  {
                    'label': 'Średnia prędkość',
                    'value': _summaryData['Średnia prędkość']!,
                    'icon': Icons.speed,
                  },
                ],
                cardColor: _cardColor,
              ),
            ),
            const Spacer(),
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

  Widget _buildPeriodButton(String label, Color color, {bool isCustom = false}) {
    return ElevatedButton(
      onPressed: () {
        if (isCustom) {
          _selectCustomPeriod();
        } else {
          _updateSummary(label, color);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
