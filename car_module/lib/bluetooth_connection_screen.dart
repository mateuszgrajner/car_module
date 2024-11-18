import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app_bar_custom.dart';

class BluetoothConnectionScreen extends StatefulWidget {
  const BluetoothConnectionScreen({super.key});

  @override
  _BluetoothConnectionScreenState createState() => _BluetoothConnectionScreenState();
}

class _BluetoothConnectionScreenState extends State<BluetoothConnectionScreen> {
  List<BluetoothDevice> _pairedDevices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnecting = false;

  // UUID dla SPP (Serial Port Profile)
  final Guid sppUuid = Guid('00001101-0000-1000-8000-00805F9B34FB');

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _getPairedDevices();
  }

  /// Żądanie wymaganych uprawnień
  void _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }

  /// Pobieranie sparowanych urządzeń
  void _getPairedDevices() async {
    List<BluetoothDevice> devices = await FlutterBluePlus.bondedDevices;
    setState(() {
      _pairedDevices = devices;
    });
  }

  /// Funkcja połączenia z urządzeniem
  void _connectToDevice() async {
    if (_selectedDevice != null) {
      setState(() {
        _isConnecting = true;
      });

      try {
        debugPrint('Próba połączenia z urządzeniem: ${_selectedDevice!.name}');

        // Połączenie z urządzeniem
        await _selectedDevice!.connect(autoConnect: false);
        debugPrint('Połączono z urządzeniem: ${_selectedDevice!.name}');

        // Ustawienie MTU na 256
        await _selectedDevice!.requestMtu(256);
        debugPrint('MTU ustawione na 256.');

        setState(() {
          _isConnecting = false;
        });

        // Wyświetlenie komunikatu o sukcesie
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pomyślnie połączono z urządzeniem: ${_selectedDevice!.name}'),
            backgroundColor: Colors.green,
          ),
        );

        // Powrót do poprzedniego ekranu z wybranym urządzeniem
        Navigator.pop(context, _selectedDevice);
      } catch (e) {
        setState(() {
          _isConnecting = false;
        });
        // Obsługa błędu
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nie udało się połączyć z urządzeniem: $e'),
            backgroundColor: Colors.red,
          ),
        );
        debugPrint('Błąd podczas połączenia: $e');
      }
    }
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
            AppBarCustom(
              title: 'Połączenie z modułem OBD',
              backgroundColor: const Color.fromARGB(255, 144, 67, 239),
            ),
            const SizedBox(height: 16.0),
            // Lista sparowanych urządzeń
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<BluetoothDevice>(
                hint: const Text(
                  'Wybierz urządzenie',
                  style: TextStyle(color: Colors.white),
                ),
                dropdownColor: Colors.grey[800],
                value: _selectedDevice,
                items: _pairedDevices.map((device) {
                  return DropdownMenuItem(
                    value: device,
                    child: Text(
                      device.name.isNotEmpty ? device.name : device.remoteId.id,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (device) {
                  setState(() {
                    _selectedDevice = device;
                  });
                },
              ),
            ),
            const SizedBox(height: 16.0),
            // Przycisk połączenia
            ElevatedButton(
              onPressed: _isConnecting ? null : _connectToDevice,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isConnecting ? Colors.grey : Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 150.0, vertical: 16.0),
              ),
              child: _isConnecting
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    )
                  : const Text(
                      'Połącz',
                      style: TextStyle(color: Colors.black),
                    ),
            ),
            const Spacer(),
            // Przycisk powrotu
            Padding(
              padding: const EdgeInsets.all(16.0),
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
          ],
        ),
      ),
      // Przycisk włączania Bluetooth
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.bluetooth),
          onPressed: () async {
            try {
              await FlutterBluePlus.turnOn();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bluetooth został włączony'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Nie udało się włączyć Bluetooth: $e'),
                  backgroundColor: Colors.red,
                ),
              );
              debugPrint('Nie udało się włączyć Bluetooth: $e');
            }
          },
        ),
      ),
    );
  }
}
