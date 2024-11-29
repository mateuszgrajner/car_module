import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'obd_connection.dart';

class RealObdConnection implements ObdConnection {
  final BluetoothDevice device;
  BluetoothCharacteristic? _characteristic;
  bool _isConnected = false;

  RealObdConnection(this.device);

  @override
  Future<void> connect() async {
    print('RealObdConnection: Próba połączenia z ${device.name}');
    try {
      await device.connect();
      print('Połączono z ${device.name}');

      _isConnected = true;

      // Odczytaj usługi i charakterystyki
      final services = await device.discoverServices();
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write && characteristic.properties.read) {
            _characteristic = characteristic;
            print('Znaleziono charakterystykę: ${characteristic.uuid}');
            break;
          }
        }
        if (_characteristic != null) {
          break;
        }
      }

      if (_characteristic == null) {
        throw Exception('Nie znaleziono odpowiedniej charakterystyki.');
      }
    } catch (e) {
      _isConnected = false;
      print('Błąd podczas łączenia z urządzeniem: $e');
      rethrow; // Przekaż wyjątek do wyższego poziomu
    }
  }

  @override
  Future<void> disconnect() async {
    print('Rozłączanie urządzenia ${device.name}...');
    try {
      await device.disconnect();
      print('Urządzenie rozłączone.');
    } catch (e) {
      print('Błąd podczas rozłączania: $e');
    } finally {
      _isConnected = false;
    }
  }

  @override
  Future<String> sendCommand(String command) async {
    if (!_isConnected || _characteristic == null) {
      throw Exception('Nie połączono z urządzeniem.');
    }
    print('Wysyłanie komendy: $command');
    try {
      await _characteristic!.write(utf8.encode(command), withoutResponse: true);
      final responseBytes = await _characteristic!.read();
      final response = utf8.decode(responseBytes);
      print('Otrzymano odpowiedź: $response');
      return response;
    } catch (e) {
      print('Błąd podczas wysyłania komendy: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    // Zwolnij zasoby, jeśli to konieczne
    print('RealObdConnection: Zwalnianie zasobów.');
    _characteristic = null;
    _isConnected = false;
  }
}
