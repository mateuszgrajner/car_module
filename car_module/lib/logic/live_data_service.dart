import 'dart:async';
import 'package:car_module/logic/database_helper.dart';
import 'package:flutter/material.dart';
import 'obd_connection.dart';

class LiveDataService {
  static final LiveDataService _instance = LiveDataService._internal();
  factory LiveDataService() => _instance;

  LiveDataService._internal();

  Timer? _dataCollectionTimer;
  bool _isCollectingData = false;

  ObdConnection? _obdConnection; // Dynamiczna implementacja połączenia OBD

  // Kontrolery strumieni danych
  final _speedController = StreamController<double>.broadcast();
  final _temperatureController = StreamController<double>.broadcast();
  final _fuelConsumptionController = StreamController<double>.broadcast();
  final _rpmController = StreamController<double>.broadcast();

  // Gettery dla strumieni danych
  Stream<double> get speedStream => _speedController.stream;
  Stream<double> get temperatureStream => _temperatureController.stream;
  Stream<double> get fuelConsumptionStream => _fuelConsumptionController.stream;
  Stream<double> get rpmStream => _rpmController.stream;

  /// Ustaw implementację połączenia OBD
  void setObdConnection(ObdConnection connection) {
    _obdConnection = connection;
    debugPrint('Ustawiono połączenie OBD: $connection');
  }

  /// Rozpoczyna zbieranie danych (obsługuje zarówno tryb symulacji, jak i prawdziwe połączenie)
  void startDataCollection() {
    if (_isCollectingData) {
      debugPrint('Zbieranie danych już trwa.');
      return;
    }

    if (_obdConnection == null) {
      throw Exception('Brak ustawionego połączenia OBD.');
    }

    _isCollectingData = true;
    debugPrint('Rozpoczynanie zbierania danych...');

    _dataCollectionTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_isCollectingData) {
        try {
          final speed = await _fetchValue('010D'); // Prędkość
          final temperature = await _fetchValue('0105'); // Temperatura
          final fuelConsumption = await _fetchValue('015E'); // Spalanie
          final rpm = await _fetchValue('010C'); // Obroty silnika

          // Emituj dane do strumieni
          _speedController.add(speed);
          _temperatureController.add(temperature);
          _fuelConsumptionController.add(fuelConsumption);
          _rpmController.add(rpm);

          // Logowanie danych w bazie
          final dbHelper = DatabaseHelper.instance;
          await dbHelper.insertLiveDataLog(
            speed: speed,
            temperature: temperature,
            fuelConsumption: fuelConsumption,
          );

          debugPrint(
              'Dane zapisane: Speed=$speed, Temp=$temperature, Fuel=$fuelConsumption, RPM=$rpm');
        } catch (e) {
          debugPrint('Błąd podczas zbierania danych: $e');
          stopDataCollection(); // Zatrzymanie zbierania danych w przypadku błędu
        }
      }
    });
  }

  /// Pobierz wartość z połączenia OBD
  Future<double> _fetchValue(String command) async {
    try {
      final response = await _obdConnection!.sendCommand(command);
      final parts = response.split(' ');
      return double.tryParse(parts.last) ?? 0.0;
    } catch (e) {
      debugPrint('Błąd podczas pobierania wartości: $e');
      return 0.0;
    }
  }

  /// Zatrzymuje zbieranie danych
  void stopDataCollection() {
    if (_isCollectingData) {
      _dataCollectionTimer?.cancel();
      _isCollectingData = false;
      debugPrint('Zbieranie danych zatrzymane.');
    } else {
      debugPrint('Brak aktywnego zbierania danych do zatrzymania.');
    }
  }

  /// Rozłącza połączenie OBD
  Future<void> disconnectObdConnection() async {
    if (_obdConnection != null) {
      try {
        await _obdConnection!.disconnect();
        debugPrint('Połączenie OBD zostało rozłączone.');
      } catch (e) {
        debugPrint('Błąd podczas rozłączania połączenia OBD: $e');
      } finally {
        _obdConnection = null;
      }
    } else {
      debugPrint('Brak aktywnego połączenia OBD do rozłączenia.');
    }
  }

  /// Zwalnia zasoby
  void dispose() {
    _speedController.close();
    _temperatureController.close();
    _fuelConsumptionController.close();
    _rpmController.close();
    stopDataCollection();
    disconnectObdConnection();
    debugPrint('LiveDataService zamknięty.');
  }
}
