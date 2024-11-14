import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'feature_card.dart';
import 'app_bar_custom.dart';
import 'white_container.dart';
import 'dart:async';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isConnected = false;
  bool isTestMode = false;
  BluetoothDevice? connectedDevice;
  Timer? _backgroundDataTimer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 28, 26, 31), // Jasny szary
              Color.fromARGB(255, 49, 49, 49), // Ciemny szary
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppBarCustom(title: 'Car Module'),
            const SizedBox(height: 16.0),
            // Grid z przyciskami opcji
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0), // Przesunięcie kart od krawędzi ekranu
                child: GridView.extent(
                  maxCrossAxisExtent: 180.0, // Określenie maksymalnej szerokości dla kart
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: 0.75, // Zwiększenie wysokości kart
                  children: [
                    FeatureCard(
                      icon: Icons.error_outline,
                      label: 'Odczyt błędów',
                      color: const Color.fromARGB(255, 174, 159, 44),
                      onTap: () {
                        _navigateOrShowWarning(context, '/error');
                      },
                    ),
                    FeatureCard(
                      icon: Icons.speed,
                      label: 'Dane na żywo',
                      color: Colors.purple,
                      onTap: () {
                        _navigateOrShowWarning(context, '/data_home');
                      },
                    ),
                    FeatureCard(
                      icon: Icons.insights,
                      label: 'Historia odczytów',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pushNamed(context, '/history_home');
                      },
                    ),
                    FeatureCard(
                      icon: Icons.settings,
                      label: 'Ustawienia',
                      color: Colors.deepPurple,
                      onTap: () {
                        Navigator.pushNamed(context, '/settings_screen');
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Status połączenia i przyciski
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: WhiteContainer(
                child: Column(
                  children: [
                    Text(
                      isConnected
                          ? 'Połączenie: połączono z ${connectedDevice?.name ?? 'Nieznane urządzenie'}'
                          : 'Połączenie: brak połączenia',
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Color.fromARGB(255, 0, 0, 0), // Jasny tekst dla ciemnego tła
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (isTestMode) {
                                _exitTestMode();
                              } else if (isConnected) {
                                setState(() {
                                  isConnected = false;
                                  connectedDevice = null;
                                });
                              } else {
                                final selectedDevice = await Navigator.pushNamed(context, '/bluetooth');
                                if (selectedDevice != null && selectedDevice is BluetoothDevice) {
                                  setState(() {
                                    isConnected = true;
                                    connectedDevice = selectedDevice;
                                  });
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (isConnected || isTestMode) ? Colors.red : Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            child: Text(
                              isTestMode ? 'Zakończ demo' : (isConnected ? 'Rozłącz' : 'Połącz'),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              _showTestModeDialog(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 171, 180, 43),
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            child: const Text(
                              'Demo',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Funkcja do nawigacji lub wyświetlenia ostrzeżenia
  void _navigateOrShowWarning(BuildContext context, String route) {
    if ((isTestMode || isConnected) || route == '/history_home') {
      Navigator.pushNamed(context, route);
    } else {
      _showNoConnectionDialog(context);
    }
  }

  // Funkcja do wyświetlenia dialogu "Brak połączenia"
  void _showNoConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Brak połączenia z modułem OBD'),
          content: const Text('Włącz tryb testowy lub połącz z modułem OBD, aby uzyskać dostęp do tej funkcji.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Zamknięcie dialogu
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Funkcja do wyświetlenia dialogu dla trybu testowego
  void _showTestModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tryb Testowy'),
          content: const Text(
            'Przejście do trybu testowego rozpocznie symulację wszystkich czujników. Czy chcesz przejść w tryb testowy?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Zamknięcie dialogu
              },
              child: const Text('Anuluj'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Zamknięcie dialogu
                _enterTestMode(); // Wejście w tryb testowy
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Funkcja do wejścia w tryb testowy
  void _enterTestMode() {
    setState(() {
      isTestMode = true;
      debugPrint('Tryb testowy włączony.');
    });
    _startCollectingDataForAllScreens();
  }

  // Funkcja do zakończenia trybu testowego
  void _exitTestMode() {
    setState(() {
      isTestMode = false;
      debugPrint('Tryb testowy zakończony.');
    });
    _backgroundDataTimer?.cancel();
  }

  // Funkcja do uruchomienia symulacji danych dla wszystkich ekranów w tle
  void _startCollectingDataForAllScreens() {
    _backgroundDataTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Symulujemy wartość danych dla ekranów
      double simulatedSpeed = Random().nextDouble() * 240; // Prędkość od 0 do 240 km/h
      double simulatedTemperature = Random().nextDouble() * 160; // Temperatura od 0 do 160°C
      double simulatedFuelConsumption = Random().nextDouble() * 20; // Spalanie od 0 do 20 L/100km

      // Tutaj można zapisać dane do bazy lub innej logiki
      debugPrint('Speed: $simulatedSpeed km/h, Temperature: $simulatedTemperature °C, Fuel: $simulatedFuelConsumption L/100km');
    });
  }
}
