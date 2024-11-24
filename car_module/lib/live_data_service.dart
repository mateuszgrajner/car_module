import 'dart:async';
import 'dart:math';
import 'package:car_module/database_helper.dart';
import 'package:flutter/material.dart';
import 'obd_connection.dart';

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
  debugPrint('Ustawiono połączenie OBD: $connection');
}


  /// Rozpoczyna zbieranie danych
  void startDataCollection() {
    if (_isCollectingData) {
      debugPrint('Zbieranie danych już trwa, pomijam.');
      return;
    }

    if (_obdConnection == null) {
      throw Exception('Brak ustawionego połączenia OBD.');
    }

    _isCollectingData = true;
    debugPrint('Rozpoczynanie zbierania danych...');

    _dataCollectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_isCollectingData) {
        try {
          // Pobierz dane z OBD (lub symuluj w trybie demo)
          final simulatedSpeed = double.tryParse(await _obdConnection!.sendCommand('GET_SPEED')) ?? 0.0;
          final simulatedTemperature = double.tryParse(await _obdConnection!.sendCommand('GET_TEMP')) ?? 0.0;
          final simulatedFuelConsumption = double.tryParse(await _obdConnection!.sendCommand('GET_FUEL')) ?? 0.0;
          final simulatedRPM = double.tryParse(await _obdConnection!.sendCommand('GET_RPM')) ?? 0.0;

          // Wysyłanie danych do strumieni
          _speedController.add(simulatedSpeed);
          _temperatureController.add(simulatedTemperature);
          _fuelConsumptionController.add(simulatedFuelConsumption);
          _rpmController.add(simulatedRPM);

          // Logowanie danych w bazie
          final dbHelper = DatabaseHelper.instance;
          await dbHelper.insertLiveDataLog(
            fuelConsumption: simulatedFuelConsumption,
            temperature: simulatedTemperature,
            speed: simulatedSpeed,
          );
          print('Dane zapisane w bazie: Speed = $simulatedSpeed, Temp = $simulatedTemperature, Fuel = $simulatedFuelConsumption, RPM = $simulatedRPM');
        } catch (e) {
          print('Błąd podczas zbierania danych: $e');
          stopDataCollection(); // Zatrzymanie zbierania danych w przypadku błędu
        }
      }
    });
  }

  /// Zatrzymuje zbieranie danych
  void stopDataCollection() {
    if (_isCollectingData) {
      _dataCollectionTimer?.cancel();
      _isCollectingData = false;
      print('Zbieranie danych zatrzymane.');
    } else {
      print('Brak aktywnego zbierania danych do zatrzymania.');
    }
  }

  /// Rozłącza połączenie OBD
  Future<void> disconnectObdConnection() async {
    if (_obdConnection != null) {
      try {
        await _obdConnection!.disconnect();
        print('Połączenie OBD zostało rozłączone.');
      } catch (e) {
        print('Błąd podczas rozłączania połączenia OBD: $e');
      } finally {
        _obdConnection = null; // Wyzerowanie połączenia
      }
    } else {
      print('Brak aktywnego połączenia OBD do rozłączenia.');
    }
  }

  /// Zwalnia zasoby
  void dispose() {
    _speedController.close();
    _temperatureController.close();
    _fuelConsumptionController.close();
    _rpmController.close();
    stopDataCollection();
    disconnectObdConnection(); // Upewnij się, że połączenie jest rozłączone
    print('LiveDataService zamknięty.');
  }
}
