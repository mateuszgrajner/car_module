import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'live_data_service.dart';

class HomeController {
  bool isConnected = false; // Status połączenia Bluetooth
  bool isTestMode = false; // Status trybu testowego
  BluetoothDevice? connectedDevice; // Połączone urządzenie
  final LiveDataService liveDataService = LiveDataService();

  // Flaga kontrolująca, czy zbieranie danych trwa
  bool isCollectingData = false;

  /// Połącz z urządzeniem Bluetooth
  void connectToDevice(BluetoothDevice device) {
    if (!isConnected) {
      connectedDevice = device;
      isConnected = true;
      print('Połączono z urządzeniem: ${device.name}');
      startDataCollectionIfNeeded();
    } else {
      print('Urządzenie już jest połączone, pomijam ponowne połączenie.');
    }
  }

  /// Rozłącz urządzenie Bluetooth
  void disconnectDevice() {
    if (isConnected) {
      print('Rozłączanie urządzenia Bluetooth...');
      isConnected = false;
      connectedDevice = null;
      stopDataCollectionIfNeeded();
    } else {
      print('Brak połączonego urządzenia, nie można rozłączyć.');
    }
  }

  /// Włącz tryb testowy
  void enterTestMode() {
    if (!isTestMode) {
      print('Włączanie trybu testowego...');
      isTestMode = true;
      startDataCollectionIfNeeded();
    } else {
      print('Tryb testowy już jest włączony, pomijam.');
    }
  }

  /// Wyłącz tryb testowy
  void exitTestMode() {
    if (isTestMode) {
      print('Wyłączanie trybu testowego...');
      isTestMode = false;
      stopDataCollectionIfNeeded();
    } else {
      print('Tryb testowy nie jest włączony, pomijam wyłączanie.');
    }
  }

  /// Rozpocznij zbieranie danych, jeśli wymagany jest tryb testowy lub połączenie Bluetooth
  void startDataCollectionIfNeeded() {
    if (!isCollectingData && (isTestMode || isConnected)) {
      print('Uruchamianie timeru i generowanie danych (Tryb testowy lub OBD)');
      stopDataCollectionIfNeeded();
      liveDataService.startDataCollection();
      isCollectingData = true;
    } else {
      print('Zbieranie danych już trwa lub nie ma potrzeby uruchomienia.');
    }
  }

  /// Zatrzymaj zbieranie danych, jeśli żaden tryb nie jest aktywny
  void stopDataCollectionIfNeeded() {
    if (isCollectingData && !isTestMode && !isConnected) {
      print('Zatrzymywanie zbierania danych...');
      liveDataService.stopDataCollection();
      isCollectingData = false;
    } else {
      print('Zbieranie danych nie trwa lub jest nadal potrzebne, pomijam zatrzymanie.');
    }
  }

  /// Zwolnij zasoby
  void dispose() {
    print('Zamykanie HomeController...');
    liveDataService.dispose();
  }
}
