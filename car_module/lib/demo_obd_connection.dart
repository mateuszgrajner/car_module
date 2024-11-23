import 'dart:async';
import 'dart:math';
import 'obd_connection.dart';

class DemoObdConnection implements ObdConnection {
  bool _isConnected = false;

  @override
  Future<void> connect() async {
    _isConnected = true;
    print('DemoObdConnection: Połączono (tryb demo).');
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    print('DemoObdConnection: Rozłączono (tryb demo).');
  }

  @override
  Future<String> sendCommand(String command) async {
    if (!_isConnected) {
      throw Exception('DemoObdConnection: Nie połączono.');
    }

    // Symulacja odpowiedzi na komendę OBD z losowymi wartościami
    final random = Random();
    switch (command) {
      case 'GET_SPEED':
        return (random.nextDouble() * 240).toStringAsFixed(2);
      case 'GET_TEMP':
        return (random.nextDouble() * 160).toStringAsFixed(2);
      case 'GET_FUEL':
        return (random.nextDouble() * 20).toStringAsFixed(2);
      case 'GET_RPM':
        return (random.nextDouble() * 10000).toStringAsFixed(0);
      default:
        return '0.0'; // Domyślna wartość dla nieznanych komend
    }
  }
}
