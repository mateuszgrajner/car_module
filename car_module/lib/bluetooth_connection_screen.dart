import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'white_container.dart';

class BluetoothConnectionScreen extends StatefulWidget {
  const BluetoothConnectionScreen({super.key});

  @override
  _BluetoothConnectionScreenState createState() => _BluetoothConnectionScreenState();
}

class _BluetoothConnectionScreenState extends State<BluetoothConnectionScreen> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _getPairedDevices();
    _addSampleDevices(); // Add sample devices for testing
  }

  Future<void> _getPairedDevices() async {
    List<BluetoothDevice> devices = [];
    try {
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } on Exception {
      debugPrint('Error getting bonded devices.');
    }

    setState(() {
      _devicesList = devices;
    });
  }

  void _addSampleDevices() {
    // Adding sample devices to the list
    setState(() {
      _devicesList.addAll([
        BluetoothDevice(name: 'OBD-II Device 1', address: '00:11:22:33:44:55'),
        BluetoothDevice(name: 'OBD-II Device 2', address: '66:77:88:99:AA:BB'),
        BluetoothDevice(name: 'Test Device', address: 'CC:DD:EE:FF:00:11'),
      ]);
    });
  }

  void _connectToDevice() async {
    if (_selectedDevice != null) {
      setState(() {
        _isConnecting = true;
      });
      try {
        BluetoothConnection connection = await BluetoothConnection.toAddress(_selectedDevice!.address);
        setState(() {
          _isConnecting = false;
        });
        debugPrint('Connected to ${_selectedDevice!.name}');
        Navigator.pop(context, _selectedDevice); // Return to the main screen and pass the selected device
      } catch (e) {
        setState(() {
          _isConnecting = false;
        });
        debugPrint('Could not connect to device.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Połączenie z modułem OBD'),
        backgroundColor: Colors.deepPurple,
      ),
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
          children: [
            const SizedBox(height: 16.0),
            _bluetoothState == BluetoothState.STATE_OFF
                ? const Text(
                    'Bluetooth jest wyłączony. Proszę włączyć Bluetooth.',
                    style: TextStyle(color: Colors.white),
                  )
                : const SizedBox(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<BluetoothDevice>(
                hint: const Text(
                  'Wybierz urządzenie',
                  style: TextStyle(color: Colors.white),
                ),
                dropdownColor: Colors.grey[800],
                value: _selectedDevice,
                items: _devicesList.map((device) {
                  return DropdownMenuItem(
                    value: device,
                    child: Text(
                      device.name ?? 'Nieznane urządzenie',
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
