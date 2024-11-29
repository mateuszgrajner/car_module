import 'dart:async';
import 'dart:math';

import 'package:car_module/obd_connection.dart';

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
    _isConnected = true;
    print('DemoObdConnection: Połączono (tryb demo).');
    _generateRandomDtcCodes();
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

    // Odpowiedzi na symulowane komendy OBD
    switch (command) {
      case '010C': // Obroty silnika (RPM)
        return '41 0C ${_formatHexValue(_vehicleState['rpm']! / 4, 4)}';
      case '010D': // Prędkość pojazdu (km/h)
        return '41 0D ${_formatHexValue(_vehicleState['speed']!, 2)}';
      case '0105': // Temperatura płynu chłodzącego (°C)
        return '41 05 ${_formatHexValue(_vehicleState['temp']! - 40, 2)}';
      case '015E': // Zużycie paliwa (l/100km)
        return '41 5E ${_formatHexValue(_vehicleState['fuel']!, 2)}';
      case '03': // Odczyt kodów błędów
        return _dtcCodes.isNotEmpty ? _dtcCodes.join(',') : 'NO DATA';
      case '04': // Kasowanie błędów
        _dtcCodes.clear();
        return 'OK';
      default:
        return 'NO DATA'; // Domyślna odpowiedź na nieznane komendy
    }
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
      // Etap 1: Przyspieszanie
      int elapsedTime = _simulationStep;
      _accelerate(120.0, 15, elapsedTime);
    } else if (_simulationStep <= 30) {
      // Etap 2: Stała prędkość
      _maintainSpeed(120.0);
    } else if (_simulationStep <= 45) {
      // Etap 3: Zwalnianie
      int elapsedTime = _simulationStep - 30;
      _decelerate(0.0, 15, elapsedTime);
    } else if (_simulationStep <= 60) {
      // Etap 4: Postój
      _idle();
    } else {
      // Reset cyklu symulacji
      _simulationStep = 0;
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
    if (_vehicleState['speed']! > 0) {
      _vehicleState['rpm'] = 1000.0 + (_vehicleState['speed']! * 30.0);
    } else {
      _vehicleState['rpm'] = 800.0;
    }
  }

  /// Aktualizacja zużycia paliwa
  void _updateFuelConsumption() {
    final rpm = _vehicleState['rpm']!;
    final speed = _vehicleState['speed']!;
    if (speed > 0) {
      _vehicleState['fuel'] = 5.0 + (rpm / 1000.0) + (speed / 50.0);
    } else {
      _vehicleState['fuel'] = 0.8;
    }
    // Zapewnienie, że spalanie nie jest ujemne ani zerowe
    if (_vehicleState['fuel']! <= 0) {
      _vehicleState['fuel'] = 0.8;
    }
  }

  /// Aktualizacja temperatury
  void _updateTemperature() {
    if (_vehicleState['speed']! > 0) {
      _vehicleState['temp'] = min(90.0, _vehicleState['temp']! + 1.0);
    } else {
      _vehicleState['temp'] = max(20.0, _vehicleState['temp']! - 0.5);
    }
    if (_vehicleState['temp']! <= 0) {
      _vehicleState['temp'] = 20.0;
    }
  }

  /// Generuje losowe kody błędów (symulacja)
  void _generateRandomDtcCodes() {
    final random = Random();
    _dtcCodes = List.generate(
      random.nextInt(4) + 1, // Losowa liczba błędów (1-4)
      (index) => 'P${random.nextInt(1467).toString().padLeft(4, '0')}',
    );
    print('Wygenerowane kody błędów: $_dtcCodes');
  }

  /// Logowanie stanu pojazdu
  void _logSimulationState() {
    print('Symulacja: '
        'Step=$_simulationStep, '
        'Speed=${_vehicleState['speed']}, '
        'RPM=${_vehicleState['rpm']}, '
        'Fuel=${_vehicleState['fuel']}, '
        'Temp=${_vehicleState['temp']}');
  }

  /// Formatuje wartości na postać szesnastkową dla OBD
  String _formatHexValue(double value, int length) {
    final intValue = value.round();
    return intValue.toRadixString(16).padLeft(length, '0').toUpperCase();
  }
}