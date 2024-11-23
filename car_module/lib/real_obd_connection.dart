import 'dart:async';
import 'obd_connection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class RealObdConnection implements ObdConnection {
  final BluetoothDevice device;
  BluetoothCharacteristic? _characteristic;
  bool _isConnected = false;

  RealObdConnection(this.device);

  @override
  Future<void> connect() async {
    print('RealObdConnection: Próba połączenia z ${device.name}');
    await device.connect();
    _isConnected = true;

    // Odczytaj charakterystyki (dla przykładu)
    final services = await device.discoverServices();
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.write && characteristic.properties.read) {
          _characteristic = characteristic;
          break;
        }
      }
    }

    if (_characteristic == null) {
      throw Exception('RealObdConnection: Nie znaleziono odpowiedniej charakterystyki.');
    }

    print('RealObdConnection: Połączono z ${device.name}');
  }

  @override
  Future<void> disconnect() async {
    await device.disconnect();
    _isConnected = false;
    print('RealObdConnection: Rozłączono z ${device.name}');
  }

  @override
  Future<String> sendCommand(String command) async {
    if (!_isConnected || _characteristic == null) {
      throw Exception('RealObdConnection: Nie połączono.');
    }

    // Wyślij komendę i odczytaj odpowiedź
    await _characteristic!.write(command.codeUnits, withoutResponse: true);
    final response = await _characteristic!.read();
    return String.fromCharCodes(response);
  }
}
