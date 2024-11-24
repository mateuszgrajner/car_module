import 'package:car_module/bluetooth_connection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue_plus; // Alias dla flutter_blue_plus
import 'home_controller.dart';
import 'feature_card.dart';
import 'app_bar_custom.dart';
import 'white_container.dart';
import 'bluetooth_connection_service.dart';

class HomeScreen extends StatefulWidget {
  final BluetoothConnectionService bluetoothService;

  const HomeScreen({required this.bluetoothService, super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(widget.bluetoothService);
    _controller.addListener(_updateUI);
  }

  void _updateUI() {
    setState(() {
      // Odśwież interfejs po zmianie stanu kontrolera
    });
  }

  @override
  void dispose() {
    print('Zamykanie ekranu HomeScreen...');
    _controller.removeListener(_updateUI);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('HomeScreen - isConnected: ${_controller.isConnected.value}'); // Logujemy status
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
                        debugPrint('Navigating to /error screen.');
                        _navigateOrShowWarning(context, '/error');
                      },
                    ),
                    FeatureCard(
                      icon: Icons.speed,
                      label: 'Dane na żywo',
                      color: Colors.purple,
                      onTap: () {
                        debugPrint('Navigating to /data_home screen.');
                        _navigateOrShowWarning(context, '/data_home');
                      },
                    ),
                    FeatureCard(
                      icon: Icons.insights,
                      label: 'Historia odczytów',
                      color: Colors.green,
                      onTap: () {
                        debugPrint('Navigating to /history_home screen.');
                        Navigator.pushNamed(context, '/history_home');
                      },
                    ),
                    FeatureCard(
                      icon: Icons.settings,
                      label: 'Ustawienia',
                      color: Colors.deepPurple,
                      onTap: () {
                        debugPrint('Navigating to /settings_screen.');
                        Navigator.pushNamed(context, '/settings_screen');
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: WhiteContainer(
                child: Column(
                  children: [
                    Text(
                      _controller.isConnected.value
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
                              debugPrint('Button pressed.');
                              if (_controller.isTestMode) {
                                debugPrint('Exiting test mode...');
                                await _controller.exitTestMode();
                              } else if (_controller.isConnected.value) {
                                debugPrint('Disconnecting device...');
                                await _controller.disconnectDevice();
                              } else {
                                debugPrint('Navigating to Bluetooth Connection Screen...');
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BluetoothConnectionScreen(
                                      bluetoothService: widget.bluetoothService,
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (_controller.isConnected.value || _controller.isTestMode)
                                  ? Colors.red
                                  : Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            child: Text(
                              _controller.isTestMode
                                  ? 'Zakończ demo'
                                  : (_controller.isConnected.value ? 'Rozłącz' : 'Połącz'),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              debugPrint('Opening test mode dialog...');
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

  void _navigateOrShowWarning(BuildContext context, String route) {
    debugPrint('Navigating to: $route');
    if ((_controller.isTestMode || _controller.isConnected.value) || route == '/history_home') {
      Navigator.pushNamed(context, route, arguments: _controller.isTestMode);
    } else {
      debugPrint('No connection available. Showing warning dialog.');
      _showNoConnectionDialog(context);
    }
  }

  void _showNoConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Brak połączenia z modułem OBD'),
          content: const Text(
              'Włącz tryb testowy lub połącz z modułem OBD, aby uzyskać dostęp do tej funkcji.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                debugPrint('Closing warning dialog.');
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showTestModeDialog(BuildContext context) {
    debugPrint('Opening test mode dialog...');
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
                debugPrint('Cancelling test mode.');
                Navigator.of(context).pop();
              },
              child: const Text('Anuluj'),
            ),
            TextButton(
              onPressed: () async {
                debugPrint('Entering test mode...');
                Navigator.of(context).pop();
                await _controller.enterTestMode();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
