import 'dart:async';
import 'dart:math';
import 'package:car_module/database_helper.dart';

class LiveDataService {
  static final LiveDataService _instance = LiveDataService._internal();
  factory LiveDataService() => _instance;

  LiveDataService._internal();

  Timer? _dataCollectionTimer;
  bool _isCollectingData = false;

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

  void startDataCollection() {
    if (_isCollectingData) {
      print('Data collection already in progress, skipping.');
      return;
    }

    _isCollectingData = true;
    print('Starting data collection...');

    _dataCollectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_isCollectingData) {
        // Generate simulated values
        double simulatedSpeed = Random().nextDouble() * 240;
        double simulatedTemperature = Random().nextDouble() * 160;
        double simulatedFuelConsumption = Random().nextDouble() * 20;
        double simulatedRPM = Random().nextDouble() * 10000;

        // Push values to the stream controllers
        _speedController.add(simulatedSpeed);
        _temperatureController.add(simulatedTemperature);
        _fuelConsumptionController.add(simulatedFuelConsumption);
        _rpmController.add(simulatedRPM);

        // Log data to database
        final dbHelper = DatabaseHelper.instance;
        await dbHelper.insertLiveDataLog(
          fuelConsumption: simulatedFuelConsumption,
          temperature: simulatedTemperature,
          speed: simulatedSpeed,
        );
        print('Data added to database: Speed = $simulatedSpeed, Temp = $simulatedTemperature, Fuel = $simulatedFuelConsumption, RPM = $simulatedRPM');
      }
    });
  }

  void stopDataCollection() {
    if (_isCollectingData) {
      _dataCollectionTimer?.cancel();
      _isCollectingData = false;
      print('Data collection stopped.');
    } else {
      print('No active data collection to stop.');
    }
  }

  void dispose() {
    _speedController.close();
    _temperatureController.close();
    _fuelConsumptionController.close();
    _rpmController.close();
    stopDataCollection();
    print('LiveDataService disposed.');
  }
}
