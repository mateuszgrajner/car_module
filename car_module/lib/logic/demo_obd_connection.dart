import 'dart:async';
import 'dart:math';
import 'package:car_module/logic/obd_connection.dart';

class DemoObdConnection implements ObdConnection {
  bool _isConnected = false;
  Timer? _simulationTimer;

  // Symulowany stan pojazdu
  final Map<String, double> _vehicleState = {
    'speed': 0.0,   // km/h
    'rpm': 800.0,   // obr./min (bieg jałowy)
    'fuel': 0.8,    // l/100 km (minimalne zużycie na biegu jałowym)
    'temp': 40.0,   // °C (początkowa temperatura silnika)
  };

  List<String> _dtcCodes = []; // Lista aktualnych kodów błędów
  int _simulationStep = 0; // Etap symulacji
  static const int maxSimulationSteps = 60; // Pełny cykl symulacji (60 sekund)

  @override
  Future<void> connect() async {
    if (_isConnected) {
      print('DemoObdConnection: Już połączono.');
      return;
    }
    _isConnected = true;
    print('DemoObdConnection: Połączono (tryb demo).');
    _generateRandomDtcCodes();
    _startSimulation();
  }

  @override
  Future<void> disconnect() async {
    if (!_isConnected) {
      print('DemoObdConnection: Już rozłączono.');
      return;
    }
    _isConnected = false;
    _simulationTimer?.cancel();
    print('DemoObdConnection: Rozłączono (tryb demo).');
  }

  @override
  Future<String> sendCommand(String command) async {
    if (!_isConnected) {
      throw Exception('DemoObdConnection: Nie połączono.');
    }

    // Odpowiedzi na symulowane komendy OBD
    switch (command) {
      case '010C': // Obroty silnika (RPM)
        return _buildObdResponse('41 0C', _vehicleState['rpm']! / 4, 4);
      case '010D': // Prędkość pojazdu (km/h)
        return _buildObdResponse('41 0D', _vehicleState['speed']!, 2);
      case '0105': // Temperatura płynu chłodzącego (°C)
        return _buildObdResponse('41 05', _vehicleState['temp']! - 40, 2);
      case '015E': // Zużycie paliwa (l/100km)
        return _buildObdResponse('41 5E', _vehicleState['fuel']!, 2);
      case '03': // Odczyt kodów błędów
        return _dtcCodes.isNotEmpty
            ? '41 03 ${_dtcCodes.map((code) => _formatErrorCode(code)).join(',')}'
            : 'NO DATA';
      case '04': // Kasowanie błędów
        _dtcCodes.clear();
        return 'OK';
      default:
        return 'NO DATA'; // Domyślna odpowiedź na nieznane komendy
    }
  }

  /// Buduje odpowiedź OBD-II w standardowym formacie
  String _buildObdResponse(String pid, double value, int dataLength) {
    String hexValue = _formatHexValue(value, dataLength);
    return '$pid $hexValue';
  }

  /// Uruchamia symulację stanu pojazdu
  void _startSimulation() {
    _simulationStep = 0; // Resetujemy symulację
    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _simulateVehicleState();
    });
  }

  /// Symuluje zmiany stanu pojazdu
  void _simulateVehicleState() {
    _simulationStep++; // Następny etap symulacji

    if (_simulationStep <= 15) {
      _accelerate(120.0, 15, _simulationStep);
    } else if (_simulationStep <= 30) {
      _maintainSpeed(120.0);
    } else if (_simulationStep <= 45) {
      _decelerate(0.0, 15, _simulationStep - 30);
    } else if (_simulationStep <= 60) {
      _idle();
    } else {
      _simulationStep = 0; // Reset cyklu
    }

    _updateTemperature();
    _logSimulationState();
  }

  /// Przyspieszanie do zadanej prędkości
  void _accelerate(double targetSpeed, int durationInSeconds, int elapsedTime) {
    double initialSpeed = 0.0;
    double speedIncrementPerSecond = (targetSpeed - initialSpeed) / durationInSeconds;
    _vehicleState['speed'] = min(targetSpeed, initialSpeed + (speedIncrementPerSecond * elapsedTime));
    _updateRpm();
    _updateFuelConsumption();
  }

  /// Utrzymanie stałej prędkości
  void _maintainSpeed(double speed) {
    _vehicleState['speed'] = speed;
    _updateRpm();
    _updateFuelConsumption();
  }

  /// Zwalnianie do zadanej prędkości
  void _decelerate(double targetSpeed, int durationInSeconds, int elapsedTime) {
    double initialSpeed = 120.0;
    double speedDecrementPerSecond = (initialSpeed - targetSpeed) / durationInSeconds;
    _vehicleState['speed'] = max(targetSpeed, initialSpeed - (speedDecrementPerSecond * elapsedTime));
    _updateRpm();
    _updateFuelConsumption();
  }

  /// Postój pojazdu
  void _idle() {
    _vehicleState['speed'] = 0.0;
    _updateRpm();
    _updateFuelConsumption();
  }

  /// Aktualizacja obrotów silnika
  void _updateRpm() {
    _vehicleState['rpm'] = _vehicleState['speed']! > 0
        ? 1000.0 + (_vehicleState['speed']! * 30.0)
        : 800.0;
  }

  /// Aktualizacja zużycia paliwa
  void _updateFuelConsumption() {
    final rpm = _vehicleState['rpm']!;
    final speed = _vehicleState['speed']!;
    _vehicleState['fuel'] = speed > 0
        ? 5.0 + (rpm / 1000.0) + (speed / 50.0)
        : 0.8;
  }

  /// Aktualizacja temperatury
  void _updateTemperature() {
    _vehicleState['temp'] = _vehicleState['speed']! > 0
        ? min(90.0, _vehicleState['temp']! + 0.5)
        : max(40.0, _vehicleState['temp']! - 0.2);
  }

  /// Generuje losowe kody błędów
  void _generateRandomDtcCodes() {
    final random = Random();
    _dtcCodes = List.generate(
      random.nextInt(4) + 1,
      (index) => 'P${random.nextInt(1000).toString().padLeft(4, '0')}',
    );
    print('Wygenerowane kody błędów: $_dtcCodes');
  }

  /// Formatowanie kodu błędu
  String _formatErrorCode(String code) {
    return code;
  }

  /// Logowanie stanu pojazdu
  void _logSimulationState() {
    print('Symulacja: Speed=${_vehicleState['speed']}, '
        'RPM=${_vehicleState['rpm']}, '
        'Fuel=${_vehicleState['fuel']}, '
        'Temp=${_vehicleState['temp']}, '
        'Errors=$_dtcCodes');
  }

  /// Formatuje wartości na postać szesnastkową dla OBD
  String _formatHexValue(double value, int length) {
    final intValue = value.round();
    return intValue.toRadixString(16).padLeft(length, '0').toUpperCase();
  }
}
