import 'dart:async';
import 'dart:math';
import 'obd_connection.dart';

enum ObdProtocol { iso9141, can, kwp2000 }

class DemoObdConnection implements ObdConnection {
  bool _isConnected = false;
  Timer? _simulationTimer;
  late ObdProtocol _protocol; // Dodanie protokołu

  // Symulowany stan pojazdu
  final Map<String, double> _vehicleState = {
    'speed': 0.0,   // km/h
    'rpm': 800.0,   // obr./min (bieg jałowy)
    'fuel': 8.0,    // l/100 km (średnie zużycie w stanie spoczynku)
    'temp': 20.0,   // °C (początkowa temperatura otoczenia)
  };

  int _simulationStep = 0; // Etap symulacji
  static const int maxSimulationSteps = 60; // Pełny cykl symulacji (60 sekund)

  @override
  Future<void> connect() async {
    _isConnected = true;
    _protocol = _chooseProtocol();
    print('DemoObdConnection: Połączono (tryb demo) z protokołem $_protocol.');
    _startSimulation();
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    _simulationTimer?.cancel();
    print('DemoObdConnection: Rozłączono (tryb demo).');
  }

  @override
  Future<String> sendCommand(String command) async {
    if (!_isConnected) {
      throw Exception('DemoObdConnection: Nie połączono.');
    }

    // Symulacja opóźnienia protokołu
    await Future.delayed(_protocolDelay());

    // Odpowiedzi na symulowane komendy OBD
    switch (command) {
      case '010C': // Obroty silnika (RPM)
        return _formatResponse('41 0C', _vehicleState['rpm']! / 4, 4);
      case '010D': // Prędkość pojazdu (km/h)
        return _formatResponse('41 0D', _vehicleState['speed']!, 2);
      case '0105': // Temperatura płynu chłodzącego (°C)
        return _formatResponse('41 05', _vehicleState['temp']! - 40, 2);
      case '015E': // Zużycie paliwa (l/100km)
        return _formatResponse('41 5E', _vehicleState['fuel']!, 2);
      default:
        return _handleUnknownCommand(command);
    }
  }

  /// Uruchamia symulację stanu pojazdu
  void _startSimulation() {
    _simulationStep = 0; // Ustawiamy na 0 przed rozpoczęciem
    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _simulateVehicleState();
    });
  }

  /// Symuluje zmiany stanu pojazdu
  void _simulateVehicleState() {
    _simulationStep++; // Następny etap symulacji

    // Symulacja etapów jazdy
    if (_simulationStep <= 15) {
      _accelerate(120.0, 15, _simulationStep); // Przyspieszanie
    } else if (_simulationStep <= 30) {
      _maintainSpeed(120.0); // Utrzymanie prędkości
    } else if (_simulationStep <= 45) {
      _decelerate(0.0, 15, _simulationStep - 30); // Zwalnianie
    } else if (_simulationStep <= 60) {
      _idle(); // Postój
    } else {
      _simulationStep = 0; // Reset cyklu symulacji
    }

    // Symulacja temperatury silnika
    if (_vehicleState['temp']! < 90.0) {
      _vehicleState['temp'] = min(90.0, _vehicleState['temp']! + 1.0);
    }
  }

  /// Wybór protokołu symulacji
  ObdProtocol _chooseProtocol() {
    final protocols = ObdProtocol.values;
    return protocols[Random().nextInt(protocols.length)];
  }

  /// Symulacja opóźnień w zależności od protokołu
  Duration _protocolDelay() {
    switch (_protocol) {
      case ObdProtocol.iso9141:
        return const Duration(milliseconds: 100);
      case ObdProtocol.can:
        return const Duration(milliseconds: 50);
      case ObdProtocol.kwp2000:
        return const Duration(milliseconds: 150);
    }
  }

  /// Przygotowanie odpowiedzi
  String _formatResponse(String prefix, double value, int length) {
    final hexValue = value.round().toRadixString(16).padLeft(length, '0').toUpperCase();
    return '$prefix $hexValue';
  }

  /// Obsługa nieznanych komend
  String _handleUnknownCommand(String command) {
    if (_protocol == ObdProtocol.iso9141 || _protocol == ObdProtocol.kwp2000) {
      return 'NO DATA'; // Standardowy brak danych
    } else if (_protocol == ObdProtocol.can) {
      return '7F $command 11'; // Kod błędu CAN
    }
    return 'ERROR';
  }

  /// Przyspieszanie do zadanej prędkości w określonym czasie
  void _accelerate(double targetSpeed, int durationInSeconds, int elapsedTime) {
    final speedIncrementPerSecond = targetSpeed / durationInSeconds;
    _vehicleState['speed'] = min(targetSpeed, speedIncrementPerSecond * elapsedTime);
    _vehicleState['fuel'] = 5.0 + (_vehicleState['speed']! / 20); // Symulacja wzrostu spalania
  }

  /// Utrzymanie stałej prędkości
  void _maintainSpeed(double speed) {
    _vehicleState['speed'] = speed;
    _vehicleState['fuel'] = 7.0; // Stałe spalanie
  }

  /// Zwalnianie do zadanej prędkości w określonym czasie
  void _decelerate(double targetSpeed, int durationInSeconds, int elapsedTime) {
    final initialSpeed = 120.0;
    final speedDecrementPerSecond = initialSpeed / durationInSeconds;
    _vehicleState['speed'] = max(targetSpeed, initialSpeed - (speedDecrementPerSecond * elapsedTime));
    _vehicleState['fuel'] = 2.0; // Spalanie spada
  }

  /// Postój pojazdu
  void _idle() {
    _vehicleState['speed'] = 0.0;
    _vehicleState['fuel'] = 0.8; // Minimalne spalanie w stanie spoczynku
  }
}
