import 'dart:async';
import 'dart:convert';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as bluetooth_serial;
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue_plus;
import 'package:flutter/material.dart';



class BluetoothConnectionService {
  bluetooth_serial.BluetoothConnection? _sppConnection;
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);
  bluetooth_serial.BluetoothDevice? sppDevice;

  /// Getter stanu połączenia
  ValueNotifier<bool> get connectionStatus => isConnected;

  /// Getter dla aktualnie połączonego urządzenia SPP
  bluetooth_serial.BluetoothDevice? get connectedDevice => sppDevice;

  /// Obsługa uprawnień (opcjonalnie do implementacji w aplikacji)
  Future<void> requestPermissions(BuildContext context) async {
    // Dodaj logikę pobierania uprawnień, jeśli potrzebna
  }

  /// Połącz z urządzeniem OBD
  Future<void> connectToOBDDevice(BuildContext context) async {
    try {
      // Krok 1: Znajdź urządzenie BLE
      blue_plus.BluetoothDevice? bleDevice = await _findBleDeviceByName("BLE Device");
      if (bleDevice == null) {
        throw Exception('Nie znaleziono urządzenia BLE.');
      }
      debugPrint('Znaleziono urządzenie BLE: ${bleDevice.name}');

      // Krok 2: Połączenie BLE
      try {
        await _connectBleDevice(bleDevice);
        debugPrint('Połączenie BLE zakończone.');
      } catch (e) {
        debugPrint('Błąd podczas połączenia BLE: $e');
      }

      // Krok 3: Skanuj urządzenia klasyczne Bluetooth
      sppDevice = await _findClassicDeviceByName("V-LINK");
      if (sppDevice == null) {
        throw Exception('Nie znaleziono urządzenia w trybie SPP.');
      }
      debugPrint('Znaleziono urządzenie w trybie SPP: ${sppDevice?.name}');

      // Krok 4: Połącz z urządzeniem SPP
      _sppConnection = await bluetooth_serial.BluetoothConnection.toAddress(sppDevice!.address);
      isConnected.value = true; // Zaktualizuj stan połączenia
      debugPrint('Połączono z urządzeniem SPP: ${sppDevice?.name}');

      // Krok 5: Wysyłanie komend do OBD
      await _initializeObdConnection();
    } catch (e) {
      debugPrint('Błąd podczas połączenia: $e');
      await disconnectDevice(); // Rozłącz w przypadku błędu
      _handleConnectionError(context, e);
    }
  }

  /// Rozłącz urządzenie
  Future<void> disconnectDevice() async {
    try {
      if (_sppConnection != null && _sppConnection!.isConnected) {
        await _sppConnection!.close();
      }
      sppDevice = null;
      isConnected.value = false; // Zaktualizuj stan połączenia
      debugPrint('Urządzenie zostało rozłączone.');
    } catch (e) {
      debugPrint('Błąd podczas rozłączania urządzenia: $e');
    }
  }

  /// Znajdź urządzenie BLE po nazwie
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

  /// Znajdź urządzenie SPP po nazwie
  Future<bluetooth_serial.BluetoothDevice?> _findClassicDeviceByName(String name) async {
    List<bluetooth_serial.BluetoothDevice> pairedDevices =
        await bluetooth_serial.FlutterBluetoothSerial.instance.getBondedDevices();

    try {
      return pairedDevices.firstWhere(
          (device) => device.name!.toLowerCase().contains(name.toLowerCase()));
    } catch (e) {
      return null;
    }
  }

  /// Połącz urządzenie BLE
  /// Połącz urządzenie BLE
Future<void> _connectBleDevice(blue_plus.BluetoothDevice device) async {
  try {
    await device.connect(autoConnect: false);
    debugPrint('Połączono z urządzeniem BLE.');

    // Zmniejsz MTU lub usuń, jeśli problem się powtarza
    await device.requestMtu(256);
    debugPrint('MTU ustawione.');

    // Zwiększ czas oczekiwania przed rozłączeniem
    await Future.delayed(const Duration(seconds: 5));
    await device.disconnect();
    debugPrint('Rozłączono urządzenie BLE.');
  } catch (e) {
    debugPrint('Błąd podczas połączenia z urządzeniem BLE: $e');
    rethrow; // Ponowne rzucenie wyjątku
  }
}


  /// Zainicjuj połączenie OBD
  Future<void> _initializeObdConnection() async {
    await _sendObdCommand('ATZ'); // Reset
    await Future.delayed(const Duration(milliseconds: 500));
    await _sendObdCommand('ATE0'); // Wyłącz echo
    await _sendObdCommand('ATL0'); // Wyłącz nową linię
    await _sendObdCommand('ATSP0'); // Automatyczny protokół
    debugPrint('Wysłano wszystkie komendy inicjalizacyjne.');
  }

  /// Wysyłanie komendy do OBD
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

  /// Obsługa błędów
  void _handleConnectionError(BuildContext context, Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Błąd połączenia: $e'),
        backgroundColor: Colors.red,
      ),
    );
    debugPrint('Błąd podczas połączenia: $e');
  }
}

