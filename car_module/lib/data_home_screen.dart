import 'package:flutter/material.dart';
import 'app_bar_custom.dart';
import 'feature_card.dart';
import 'white_container.dart';


class LiveDataScreen extends StatelessWidget {

  final Color color;
  const LiveDataScreen({super.key, required this.color});

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
            const AppBarCustom(title: 'Dane na żywo'),
            const SizedBox(height: 16.0),
            // Grid z przyciskami opcji
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: GridView.extent(
                  maxCrossAxisExtent: 180.0, // Określenie maksymalnej szerokości dla kart
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: 0.75,
                  children: [
                    FeatureCard(
                      icon: Icons.speed,
                      label: 'Obroty silnika',
                      color: const Color.fromARGB(255, 86, 35, 135),
                      onTap: () {
                       Navigator.pushNamed(context, '/rpm_screen');
                      },
                    ),
                    FeatureCard(
                      icon: Icons.thermostat,
                      label: 'Temperatura',
                      color: const Color.fromARGB(255, 183, 79, 79),
                      onTap: () {
                        Navigator.pushNamed(context, '/temp_screen');
                      },
                    ),
                    FeatureCard(
                      icon: Icons.directions_car,
                      label: 'Prędkość',
                      color: const Color.fromARGB(255, 63, 167, 153),
                      onTap: () {
                        Navigator.pushNamed(context, '/speed_screen');
                      },
                    ),
                    FeatureCard(
                      icon: Icons.local_gas_station,
                      label: 'Spalanie',
                      color: const Color.fromARGB(255, 204, 103, 196),
                      onTap: () {
                        Navigator.pushNamed(context, '/fuel_screen');
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
