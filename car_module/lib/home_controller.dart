import 'package:car_module/demo_obd_connection.dart';
import 'package:car_module/real_obd_connection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'live_data_service.dart';
import 'obd_connection.dart';

class HomeController {
  bool isConnected = false; // Status połączenia Bluetooth
  bool isTestMode = false; // Status trybu testowego
  BluetoothDevice? connectedDevice; // Połączone urządzenie
  final LiveDataService liveDataService = LiveDataService(); // LiveDataService

  // Flaga kontrolująca, czy zbieranie danych trwa
  bool isCollectingData = false;

  /// Połącz z urządzeniem Bluetooth
  Future<void> connectToDevice(BluetoothDevice device) async {
    if (isConnected) {
      print('Urządzenie już jest połączone, pomijam ponowne połączenie.');
      return;
    }

    print('Próba połączenia z urządzeniem: ${device.name}');
    try {
      // Ustawienie rzeczywistego połączenia
      final realConnection = RealObdConnection(device);
      await realConnection.connect(); // Upewniamy się, że pełne połączenie zostało nawiązane
      liveDataService.setObdConnection(realConnection);
      connectedDevice = device;
      isConnected = true; // Flaga ustawiana po pełnym sukcesie połączenia

      print('Połączono z urządzeniem: ${device.name}');
      startDataCollectionIfNeeded();
    } catch (e) {
      print('Nie udało się połączyć z urządzeniem: $e');
      disconnectDevice(); // Rozłącz w przypadku błędu
    }
  }

  /// Rozłącz urządzenie Bluetooth
  Future<void> disconnectDevice() async {
    if (isConnected) {
      print('Rozłączanie urządzenia Bluetooth...');
      await liveDataService.disconnectObdConnection(); // Odłączanie połączenia z OBD
      connectedDevice = null;
      isConnected = false;

      stopDataCollectionIfNeeded();
      print('Urządzenie rozłączone.');
    } else {
      print('Brak połączonego urządzenia, nie można rozłączyć.');
    }
  }

  /// Włącz tryb testowy
  Future<void> enterTestMode() async {
    if (isTestMode) {
      print('Tryb testowy już jest włączony, pomijam.');
      return;
    }

    print('Włączanie trybu testowego...');
    isTestMode = true;

    // Ustaw DemoObdConnection jako aktywne połączenie
    final demoConnection = DemoObdConnection();
    await demoConnection.connect(); // Upewniamy się, że DemoObdConnection jest "połączone"
    liveDataService.setObdConnection(demoConnection);

    startDataCollectionIfNeeded();
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
      print('Rozpoczynanie zbierania danych (Tryb testowy lub OBD)...');
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
