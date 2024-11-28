import 'package:flutter/material.dart';
import '../core/app_bar_custom.dart';
import '../core/feature_card.dart';
import '../core/white_container.dart';

class ReadingsHistoryScreen extends StatelessWidget {
  const ReadingsHistoryScreen({super.key});

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
            const AppBarCustom(title: 'Historia odczytów'),
            const SizedBox(height: 16.0),
            // Grid z przyciskami opcji
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: GridView.extent(
                  maxCrossAxisExtent: 200.0,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: 0.75,
                  children: [
                    FeatureCard(
                      icon: Icons.receipt_long,
                      label: 'Dziennik odczytów',
                      color: const Color.fromARGB(255, 86, 35, 135),
                      onTap: () {
                        Navigator.pushNamed(context, '/readings_screen');
                      },
                    ),
                    FeatureCard(
                      icon: Icons.show_chart,
                      label: 'Podsumowanie okresowe',
                      color: const Color.fromARGB(255, 153, 45, 163),
                      onTap: () {
                        Navigator.pushNamed(context, '/summary_screen');
                      },
                    ),
                  ],
                ),
              ),
            ),
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
