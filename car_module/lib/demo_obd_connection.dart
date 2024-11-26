import 'dart:async';
import 'dart:math';
import 'obd_connection.dart';

class DemoObdConnection implements ObdConnection {
  bool _isConnected = false;
  Timer? _simulationTimer;

  // Symulowany stan pojazdu
  final Map<String, double> _vehicleState = {
    'speed': 0.0,
    'rpm': 800.0,
    'fuel': 8.0,
    'temp': 20.0,
  };

  int _simulationStep = 0;
  static const int maxSimulationSteps = 60;

  @override
  Future<void> connect() async {
    _isConnected = true;
    print('DemoObdConnection: Połączono (tryb demo).');
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

    switch (command) {
      case '010C':
        return '41 0C ${_formatHexValue(_vehicleState['rpm']! / 4, 4)}';
      case '010D':
        return '41 0D ${_formatHexValue(_vehicleState['speed']!, 2)}';
      case '0105':
        return '41 05 ${_formatHexValue(_vehicleState['temp']! - 40, 2)}';
      case '015E':
        return '41 5E ${_formatHexValue(_vehicleState['fuel']!, 2)}';
      default:
        return 'NO DATA';
    }
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
    } else if (_simulationStep <= 60) {
      _idle();
    } else {
      _simulationStep = 0;
    }

    if (_vehicleState['temp']! < 90.0) {
      _vehicleState['temp'] = _vehicleState['temp']! + 2.0;
    } else {
      _vehicleState['temp'] = 90.0;
    }
  }

  void _accelerate(double targetSpeed, int durationInSeconds, int elapsedTime) {
    final initialSpeed = 0.0;
    final speedIncrementPerSecond = (targetSpeed - initialSpeed) / durationInSeconds;
    _vehicleState['speed'] = min(targetSpeed, initialSpeed + (speedIncrementPerSecond * elapsedTime));
    _updateRpm();
    _updateFuelConsumption();
  }

  void _maintainSpeed(double speed) {
    _vehicleState['speed'] = speed;
    _vehicleState['rpm'] = 2000.0;
    _vehicleState['fuel'] = 7.0;
  }

  void _decelerate(double targetSpeed, int durationInSeconds, int elapsedTime) {
    final initialSpeed = 120.0;
    final speedDecrementPerSecond = (initialSpeed - targetSpeed) / durationInSeconds;
    _vehicleState['speed'] = max(targetSpeed, initialSpeed - (speedDecrementPerSecond * elapsedTime));
    _updateRpm();
    _updateFuelConsumption();
  }

  void _idle() {
    _vehicleState['speed'] = 0.0;
    _vehicleState['rpm'] = 800.0;
    _vehicleState['fuel'] = 0.8;
  }

  void _updateRpm() {
    _vehicleState['rpm'] = 800.0 + (_vehicleState['speed']! * 40.0);
  }

  void _updateFuelConsumption() {
    final rpm = _vehicleState['rpm']!;
    final speed = _vehicleState['speed']!;
    _vehicleState['fuel'] = max(0.8, 2.0 + (rpm / 1000.0) + (speed / 100.0));
  }

  String _formatHexValue(double value, int length) {
    final intValue = value.round();
    return intValue.toRadixString(16).padLeft(length, '0').toUpperCase();
  }
}
