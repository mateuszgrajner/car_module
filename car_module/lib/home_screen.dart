import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Module App'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tytuł sekcji
            const Text(
              'Wybierz funkcję',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Rząd z przyciskami opcji
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                children: [
                  _buildFeatureCard(
                    context,
                    icon: Icons.error_outline,
                    label: 'Odczyt Błędów',
                    onTap: () {
                      // TODO: Dodaj nawigację do ekranu odczytu błędów
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.speed,
                    label: 'Dane na Żywo',
                    onTap: () {
                      // TODO: Dodaj nawigację do ekranu danych na żywo
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.insights,
                    label: 'Statystyki',
                    onTap: () {
                      // TODO: Dodaj nawigację do ekranu statystyk
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.bluetooth,
                    label: 'Połącz z OBD',
                    onTap: () {
                      // TODO: Dodaj nawigację do połączenia z modułem OBD
                    },
                  ),
                ],
              ),
            ),
            // Przyciski akcji na dole
            ElevatedButton(
              onPressed: () {
                // TODO: Akcja połączenia z modułem OBD
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text('Połącz z OBD'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required IconData icon,
      required String label,
      required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.deepPurple[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48.0, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
