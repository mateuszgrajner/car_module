import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'feature_card.dart';
import 'app_bar_custom.dart';
import 'white_container.dart';
import 'home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController _controller = HomeController();

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
            const AppBarCustom(title: 'Car Module'),
            const SizedBox(height: 16.0),
            // Grid z przyciskami opcji
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: GridView.extent(
                  maxCrossAxisExtent: 180.0,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: 0.75,
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
                      _controller.isConnected
                          ? 'Połączenie: połączono z ${_controller.connectedDevice?.name ?? 'Nieznane urządzenie'}'
                          : 'Połączenie: brak połączenia',
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Color.fromARGB(255, 0, 0, 0),
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
                              if (_controller.isTestMode) {
                                _controller.exitTestMode();
                              } else if (_controller.isConnected) {
                                _controller.disconnectDevice();
                              } else {
                                final selectedDevice = await Navigator.pushNamed(context, '/bluetooth');
                                if (selectedDevice != null && selectedDevice is BluetoothDevice) {
                                  _controller.connectToDevice(selectedDevice);
                                }
                              }
                              setState(() {}); // Odświeżenie UI po zmianie stanu
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (_controller.isConnected || _controller.isTestMode) ? Colors.red : Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            child: Text(
                              _controller.isTestMode ? 'Zakończ demo' : (_controller.isConnected ? 'Rozłącz' : 'Połącz'),
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
    if ((_controller.isTestMode || _controller.isConnected) || route == '/history_home') {
      Navigator.pushNamed(context, route, arguments: _controller.isTestMode);
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
                Navigator.of(context).pop();
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
              Navigator.of(context).pop();
            },
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _controller.enterTestMode();
              });
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

  @override
  void dispose() {
    print('Zamykanie ekranu HomeScreen...');
    _controller.dispose();
    super.dispose();
  }
}
