import 'dart:async';
import 'obd_connection.dart';
import 'package:car_module/database_helper.dart';

class LiveDataService {
  static final LiveDataService _instance = LiveDataService._internal();
  factory LiveDataService() => _instance;

  LiveDataService._internal();

  Timer? _dataCollectionTimer;
  bool _isCollectingData = false;

  ObdConnection? _obdConnection; // Dynamiczna implementacja połączenia OBD

  // Controllers for the different data streams
  final _speedController = StreamController<double>.broadcast();
  final _temperatureController = StreamController<double>.broadcast();
  final _fuelConsumptionController = StreamController<double>.broadcast();
  final _rpmController = StreamController<double>.broadcast();

  // Stream getters
  Stream<double> get speedStream => _speedController.stream;
  Stream<double> get temperatureStream => _temperatureController.stream;
  Stream<double> get fuelConsumptionStream => _fuelConsumptionController.stream;
  Stream<double> get rpmStream => _rpmController.stream;

  /// Ustaw implementację połączenia OBD
  void setObdConnection(ObdConnection connection) {
    _obdConnection = connection;
  }

  /// Rozłącz połączenie OBD
  Future<void> disconnectObdConnection() async {
    if (_obdConnection != null) {
      await _obdConnection!.disconnect();
      _obdConnection = null;
    }
  }

  void startDataCollection() {
    if (_isCollectingData) {
      print('Data collection already in progress, skipping.');
      return;
    }

    _isCollectingData = true;
    print('Starting data collection...');

    _dataCollectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_isCollectingData) {
        if (_obdConnection == null) {
          throw Exception('Brak ustawionego połączenia OBD.');
        }

        try {
          // Pobierz dane z OBD (lub symuluj)
          final simulatedSpeed = double.parse(await _obdConnection!.sendCommand('GET_SPEED'));
          final simulatedTemperature = double.parse(await _obdConnection!.sendCommand('GET_TEMP'));
          final simulatedFuelConsumption = double.parse(await _obdConnection!.sendCommand('GET_FUEL'));
          final simulatedRPM = double.parse(await _obdConnection!.sendCommand('GET_RPM'));

          // Przekaż wartości do kontrolerów strumieni
          _speedController.add(simulatedSpeed);
          _temperatureController.add(simulatedTemperature);
          _fuelConsumptionController.add(simulatedFuelConsumption);
          _rpmController.add(simulatedRPM);

          // Zapisz dane do bazy danych
          final dbHelper = DatabaseHelper.instance;
          await dbHelper.insertLiveDataLog(
            fuelConsumption: simulatedFuelConsumption,
            temperature: simulatedTemperature,
            speed: simulatedSpeed,
          );
        } catch (e) {
          print('Błąd podczas zbierania danych: $e');
        }
      }
    });
  }

  void stopDataCollection() {
    if (_isCollectingData) {
      _dataCollectionTimer?.cancel();
      _isCollectingData = false;
      print('Data collection stopped.');
    }
  }

  void dispose() {
    _speedController.close();
    _temperatureController.close();
    _fuelConsumptionController.close();
    _rpmController.close();
    stopDataCollection();
  }
}
