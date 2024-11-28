import 'dart:async';
import 'dart:math';
import '../models/error_code_model.dart';
import 'database_helper.dart';

class DemoObdConnection {
  bool _isConnected = false;
  Timer? _simulationTimer;

  final Map<String, double> _vehicleState = {
    'speed': 0.0,
    'rpm': 800.0,
    'fuel': 8.0,
    'temp': 20.0,
  };

  int _simulationStep = 0;
  static const int maxSimulationSteps = 60;

  List<ErrorCode> _dtcCodes = [];

  bool _isValidErrorCode(String code) {
    if (code.length != 5 || !code.startsWith('P')) return false;
    final numericPart = int.tryParse(code.substring(1));
    return numericPart != null && numericPart >= 0 && numericPart <= 1466;
  }

  Future<void> connect() async {
    _isConnected = true;
    print('DemoObdConnection: Połączono (tryb demo).');
    _generateRandomDtcCodes();
    _startSimulation();
  }

  Future<void> disconnect() async {
    _isConnected = false;
    _simulationTimer?.cancel();
    print('DemoObdConnection: Rozłączono (tryb demo).');
  }

  Future<List<ErrorCode>> fetchErrorCodes() async {
    if (!_isConnected) {
      throw Exception('DemoObdConnection: Nie połączono.');
    }

    return _dtcCodes;
  }

  Future<void> clearErrorCodes() async {
    if (!_isConnected) {
      throw Exception('DemoObdConnection: Nie połączono.');
    }
    _dtcCodes.clear();
    print('DemoObdConnection: Błędy zostały wyczyszczone.');
  }

  Future<List<ErrorCode>> mapErrorCodes() async {
    final dbHelper = DatabaseHelper.instance;
    final databaseCodes = await dbHelper.getAllErrorCodes();
    final errorCodeList = databaseCodes.map((e) => e.code.toUpperCase()).toList();

    return _dtcCodes.map((code) {
      if (errorCodeList.contains(code.code)) {
        return databaseCodes.firstWhere((dbCode) => dbCode.code == code.code);
      } else {
        return ErrorCode(
          id: 0,
          code: code.code,
          description: 'Nieznany błąd ECU',
        );
      }
    }).toList();
  }

  void _generateRandomDtcCodes() {
    final random = Random();
    _dtcCodes = List.generate(
      random.nextInt(4) + 1,
      (_) {
        final code = 'P${random.nextInt(1467).toString().padLeft(4, '0')}';
        return ErrorCode(
          id: 0,
          code: code,
          description: 'Losowy opis błędu dla kodu $code',
        );
      },
    );
  }

  void _startSimulation() {
    _simulationStep = 0;
    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _simulateVehicleState();
    });
  }

  void _simulateVehicleState() {
    _simulationStep++;
    if (_simulationStep <= 15) {
      _accelerate(120.0, 15, _simulationStep);
    } else if (_simulationStep <= 30) {
      _maintainSpeed(120.0);
    } else if (_simulationStep <= 45) {
      _decelerate(0.0, 15, _simulationStep - 30);
    } else {
      _idle();
    }
    _updateTemperature();
  }

  void _accelerate(double targetSpeed, int durationInSeconds, int elapsedTime) {
    final increment = (targetSpeed - _vehicleState['speed']!) / durationInSeconds;
    _vehicleState['speed'] = min(targetSpeed, _vehicleState['speed']! + increment);
    _updateRpm();
  }

  void _maintainSpeed(double speed) {
    _vehicleState['speed'] = speed;
    _vehicleState['rpm'] = 2000.0;
  }

  void _decelerate(double targetSpeed, int durationInSeconds, int elapsedTime) {
    final decrement = (_vehicleState['speed']! - targetSpeed) / durationInSeconds;
    _vehicleState['speed'] = max(targetSpeed, _vehicleState['speed']! - decrement);
    _updateRpm();
  }

  void _idle() {
    _vehicleState['speed'] = 0.0;
    _vehicleState['rpm'] = 800.0;
  }

  void _updateRpm() {
    _vehicleState['rpm'] = 800.0 + (_vehicleState['speed']! * 40.0);
  }

  void _updateTemperature() {
    if (_vehicleState['temp']! < 90.0) {
      _vehicleState['temp'] = _vehicleState['temp']! + 2.0;
    } else {
      _vehicleState['temp'] = 90.0;
    }
  }
}
