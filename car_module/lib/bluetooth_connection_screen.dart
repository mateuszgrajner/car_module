import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue_plus;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as bluetooth_serial;
import 'package:permission_handler/permission_handler.dart';

class BluetoothConnectionScreen extends StatefulWidget {
  const BluetoothConnectionScreen({Key? key}) : super(key: key);

  @override
  _BluetoothConnectionScreenState createState() =>
      _BluetoothConnectionScreenState();
}

class _BluetoothConnectionScreenState extends State<BluetoothConnectionScreen> {
  bool _isConnecting = false;
  bluetooth_serial.BluetoothConnection? _sppConnection;

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

    try {
      // Krok 1: Znajdź urządzenie BLE
      blue_plus.BluetoothDevice? bleDevice = await _findBleDeviceByName("BLE Device");
      if (bleDevice == null) {
        throw Exception('Nie znaleziono urządzenia BLE.');
      }
      debugPrint('Znaleziono urządzenie BLE: ${bleDevice.name}');

      // Krok 2: Krótkie połączenie BLE (opcjonalne)
      try {
        await bleDevice.connect(autoConnect: false);
        debugPrint('Tymczasowe połączenie BLE nawiązane.');
        await Future.delayed(const Duration(seconds: 3));
        await bleDevice.disconnect();
        debugPrint('BLE urządzenie rozłączone.');
      } catch (e) {
        debugPrint('Nie można nawiązać pełnego połączenia BLE: $e');
      }

      // Krok 3: Skanuj urządzenia klasyczne Bluetooth
      bluetooth_serial.BluetoothDevice? sppDevice = await _findClassicDeviceByName("V-LINK");
      if (sppDevice == null) {
        throw Exception('Nie znaleziono urządzenia w trybie SPP.');
      }
      debugPrint('Znaleziono urządzenie w trybie SPP: ${sppDevice.name}');

      // Krok 4: Połącz z urządzeniem klasycznym
      _sppConnection = await bluetooth_serial.BluetoothConnection.toAddress(sppDevice.address);
      debugPrint('Połączono z urządzeniem SPP: ${sppDevice.name}');

      // Krok 5: Wysyłanie komend do OBD
      await _sendObdCommand('ATZ'); // Reset
      await Future.delayed(const Duration(milliseconds: 500));
      await _sendObdCommand('ATE0'); // Wyłącz echo
      await _sendObdCommand('ATL0'); // Wyłącz nową linię
      await _sendObdCommand('ATSP0'); // Automatyczny protokół
      debugPrint('Wysłano wszystkie komendy inicjalizacyjne.');

      setState(() {
        _isConnecting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pomyślnie połączono z urządzeniem OBD.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _handleConnectionError(e);
    }
  }

  Future<blue_plus.BluetoothDevice?> _findBleDeviceByName(String name) async {
    final completer = Completer<blue_plus.BluetoothDevice?>();
    blue_plus.FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    blue_plus.FlutterBluePlus.scanResults.listen((results) {
      for (var result in results) {
        if (result.device.name.toLowerCase().contains(name.toLowerCase())) {
          completer.complete(result.device);
          blue_plus.FlutterBluePlus.stopScan();
          return;
        }
      }
    }).onError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }

  Future<bluetooth_serial.BluetoothDevice?> _findClassicDeviceByName(
      String name) async {
    List<bluetooth_serial.BluetoothDevice> pairedDevices =
        await bluetooth_serial.FlutterBluetoothSerial.instance.getBondedDevices();

    try {
      return pairedDevices.firstWhere(
          (device) => device.name!.toLowerCase().contains(name.toLowerCase()));
    } catch (e) {
      return null;
    }
  }

  Future<void> _sendObdCommand(String command) async {
    if (_sppConnection != null && _sppConnection!.isConnected) {
      try {
        _sppConnection!.output.add(utf8.encode('$command\r\n'));
        await _sppConnection!.output.allSent;
        debugPrint('Wysłano komendę: $command');
      } catch (e) {
        debugPrint('Błąd podczas wysyłania komendy: $e');
      }
    } else {
      throw Exception('Brak aktywnego połączenia SPP.');
    }
  }

  void _handleConnectionError(Object e) {
    setState(() {
      _isConnecting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Błąd połączenia: $e'),
        backgroundColor: Colors.red,
      ),
    );

    debugPrint('Błąd podczas łączenia: $e');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Połączenie z modułem OBD')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isConnecting ? null : _connectToOBDDevice,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                backgroundColor: _isConnecting ? Colors.grey : Colors.green,
              ),
              child: _isConnecting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Połącz z OBD', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
