import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'app_bar_custom.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothConnectionScreen extends StatefulWidget {
  const BluetoothConnectionScreen({Key? key}) : super(key: key);

  @override
  _BluetoothConnectionScreenState createState() => _BluetoothConnectionScreenState();
}

class _BluetoothConnectionScreenState extends State<BluetoothConnectionScreen> {
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _startScan();
  }

  void _requestPermissions() async {
  if (await Permission.bluetooth.isDenied) {
    await Permission.bluetooth.request();
  }
  if (await Permission.bluetoothScan.isDenied) {
    await Permission.bluetoothScan.request();
  }
  if (await Permission.bluetoothConnect.isDenied) {
    await Permission.bluetoothConnect.request();
  }
  if (await Permission.locationWhenInUse.isDenied) {
    await Permission.locationWhenInUse.request();
  }
}

  void _startScan() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 8));

    // Nasłuchiwanie wyników skanowania
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        if (results.isNotEmpty) {
          _devicesList = results.map((r) => r.device).toList();
        }
      });
    });
  }

  void _connectToDevice() async {
    if (_selectedDevice != null) {
      setState(() {
        _isConnecting = true;
      });

      try {
        // Próba połączenia z urządzeniem
        await _selectedDevice!.connect();
        setState(() {
          _isConnecting = false;
        });

        // Wyświetlenie komunikatu o połączeniu
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pomyślnie połączono z urządzeniem: ${_selectedDevice!.remoteId.id}'),
            backgroundColor: Colors.green,
          ),
        );

        debugPrint('Connected to ${_selectedDevice!.remoteId}');
        // Powrót do ekranu głównego z wybranym urządzeniem
        Navigator.pop(context, _selectedDevice);
      } catch (e) {
        setState(() {
          _isConnecting = false;
        });
        // Wyświetlenie komunikatu na ekranie w przypadku nieudanego połączenia
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nie udało się połączyć z urządzeniem: $e'),
            backgroundColor: Colors.red,
          ),
        );
        debugPrint('Nie udało się połączyć z urządzeniem: $e');
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<BluetoothDevice>(
                hint: const Text(
                  'Wybierz urządzenie',
                  style: TextStyle(color: Colors.white),
                ),
                dropdownColor: Colors.grey[800],
                value: _selectedDevice,
                items: _devicesList.isNotEmpty
                    ? _devicesList.map((device) {
                        return DropdownMenuItem(
                          value: device,
                          child: Text(
                            device.name.isNotEmpty ? device.name : device.remoteId.id,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList()
                    : [
                        DropdownMenuItem(
                          value: null,
                          child: const Text(
                            'Brak dostępnych urządzeń',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                onChanged: (device) {
                  setState(() {
                    _selectedDevice = device;
                  });
                },
              ),
            ),
            const SizedBox(height: 16.0),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // Przenieś wyżej, aby nie kolidował z dolnym przyciskiem
        child: FloatingActionButton(
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.bluetooth),
          onPressed: () async {
            try {
              // Włączenie Bluetooth
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
