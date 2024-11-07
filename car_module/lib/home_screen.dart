import 'package:flutter/material.dart';
import 'feature_card.dart';
import 'app_bar_custom.dart';
import 'white_container.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isConnected = false;
  BluetoothDevice? connectedDevice;

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
                        Navigator.pushNamed(context, '/error');
                      },
                    ),
                    FeatureCard(
                      icon: Icons.speed,
                      label: 'Dane na żywo',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.pushNamed(context, '/data_home');
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
            // Status połączenia i przycisk
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (isConnected) {
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
                          backgroundColor: isConnected ? Colors.red : Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: Text(
                          isConnected ? 'Rozłącz' : 'Połącz',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
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
}
