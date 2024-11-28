import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue_plus; // Alias dla flutter_blue_plus
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as bluetooth_serial; // Alias dla flutter_bluetooth_serial
import 'live_data_service.dart';
import 'bluetooth_connection_service.dart';
import 'obd_connection.dart';
import 'demo_obd_connection.dart';

class HomeController extends ChangeNotifier {
  final BluetoothConnectionService _bluetoothService; // Referencja do usługi Bluetooth
  final ValueNotifier<bool> isConnected; // Status połączenia Bluetooth
  bool isTestMode = false; // Status trybu testowego
  bluetooth_serial.BluetoothDevice? get connectedDevice => _bluetoothService.connectedDevice; // Getter urządzenia
  final LiveDataService liveDataService = LiveDataService(); // LiveDataService

  bool isCollectingData = false; // Flaga kontrolująca zbieranie danych

  HomeController(this._bluetoothService)
      : isConnected = _bluetoothService.isConnected {
    // Subskrybujemy zmiany w stanie połączenia
    isConnected.addListener(() {
      notifyListeners(); // Powiadamiamy UI o zmianie stanu
    });
  }

  /// Połącz z urządzeniem Bluetooth
  Future<void> connectToDevice(BuildContext context) async {
    try {
      print('Próba połączenia z urządzeniem...');
      await _bluetoothService.connectToOBDDevice(context); // Użycie usługi Bluetooth
      print('Połączono z urządzeniem: ${connectedDevice?.name}');
      startDataCollectionIfNeeded();
    } catch (e) {
      print('Nie udało się połączyć z urządzeniem: $e');
      await disconnectDevice(); // Rozłącz w przypadku błędu
    }
  }

  /// Rozłącz urządzenie Bluetooth
  Future<void> disconnectDevice() async {
    try {
      print('Rozłączanie urządzenia Bluetooth...');
      await _bluetoothService.disconnectDevice(); // Rozłącz przez usługę Bluetooth
      notifyListeners(); // Powiadamiamy UI o zmianie stanu
      stopDataCollectionIfNeeded();
      print('Urządzenie rozłączone.');
    } catch (e) {
      print('Błąd podczas rozłączania urządzenia: $e');
    }
  }

  /// Włącz tryb testowy
  Future<void> enterTestMode() async {
    if (!isTestMode) {
      print('Włączanie trybu testowego...');
      isTestMode = true;
      notifyListeners(); // Powiadamiamy UI o zmianie stanu

      // Ustaw DemoObdConnection jako aktywne połączenie
      final demoConnection = DemoObdConnection();
      await demoConnection.connect(); // Upewniamy się, że DemoObdConnection jest "połączone"
      liveDataService.setObdConnection(demoConnection as ObdConnection);

      startDataCollectionIfNeeded();
    } else {
      print('Tryb testowy już jest włączony, pomijam.');
    }
  }

  /// Wyłącz tryb testowy
  Future<void> exitTestMode() async {
    if (isTestMode) {
      print('Wyłączanie trybu testowego...');
      isTestMode = false;
      notifyListeners(); // Powiadamiamy UI o zmianie stanu
      await liveDataService.disconnectObdConnection();
      stopDataCollectionIfNeeded();
    } else {
      print('Tryb testowy nie jest włączony, pomijam wyłączanie.');
    }
  }

  /// Rozpocznij zbieranie danych, jeśli wymagany jest tryb testowy lub połączenie Bluetooth
  void startDataCollectionIfNeeded() {
    if (!isCollectingData && (isTestMode || isConnected.value)) {
      print('Rozpoczynanie zbierania danych (Tryb testowy lub OBD)...');
      liveDataService.startDataCollection();
      isCollectingData = true;
    } else {
      print('Zbieranie danych już trwa lub nie ma potrzeby uruchomienia.');
    }
  }

  /// Zatrzymaj zbieranie danych, jeśli żaden tryb nie jest aktywny
  void stopDataCollectionIfNeeded() {
    if (isCollectingData && !isTestMode && !isConnected.value) {
      print('Zatrzymywanie zbierania danych...');
      liveDataService.stopDataCollection();
      isCollectingData = false;
    } else {
      print('Zbieranie danych nie trwa lub jest nadal potrzebne, pomijam zatrzymanie.');
    }
  }

  /// Zwolnij zasoby
  @override
  void dispose() {
    print('Zamykanie HomeController...');
    liveDataService.dispose();
    isConnected.removeListener(() {
      notifyListeners();
    });
    super.dispose();
  }
}
