import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/bluetooth_connection_service.dart';

class BluetoothConnectionScreen extends StatefulWidget {
  final BluetoothConnectionService bluetoothService;

  const BluetoothConnectionScreen({Key? key, required this.bluetoothService}) : super(key: key);

  @override
  _BluetoothConnectionScreenState createState() => _BluetoothConnectionScreenState();
}

class _BluetoothConnectionScreenState extends State<BluetoothConnectionScreen> {
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  void _requestPermissions() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    if (statuses[Permission.locationWhenInUse]?.isDenied ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokalizacja jest wymagana do skanowania BLE. Włącz lokalizację.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (statuses[Permission.locationWhenInUse]?.isPermanentlyDenied ?? false) {
      openAppSettings();
    }
  }

  void _connectToOBDDevice() async {
    setState(() {
      _isConnecting = true;
    });

    await widget.bluetoothService.connectToOBDDevice(context);

    setState(() {
      _isConnecting = false;
    });

    // Powrót do poprzedniego ekranu z informacją o wyniku
    Navigator.pop(context, widget.bluetoothService.isConnected.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Połączenie z modułem OBD'),
        backgroundColor: const Color.fromARGB(255, 144, 67, 239),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isConnecting ? null : _connectToOBDDevice,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  backgroundColor: _isConnecting ? Colors.grey : Colors.green,
                ),
                child: _isConnecting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Połącz z OBD', style: TextStyle(fontSize: 18, color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
