import 'dart:async';
import 'dart:math';

class LiveDataService {
  Timer? _dataCollectionTimer;

  // Użyj strumieni do przekazywania zaktualizowanych danych do widżetów
  final _speedController = StreamController<double>.broadcast();
  final _temperatureController = StreamController<double>.broadcast();
  final _fuelConsumptionController = StreamController<double>.broadcast();
  final _rpmController = StreamController<double>.broadcast();

  Stream<double> get speedStream => _speedController.stream;
  Stream<double> get temperatureStream => _temperatureController.stream;
  Stream<double> get fuelConsumptionStream => _fuelConsumptionController.stream;
  Stream<double> get rpmStream => _rpmController.stream;

  void startDataCollection() {
    _dataCollectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Generowanie symulowanych wartości
      double simulatedSpeed = Random().nextDouble() * 240; // Prędkość od 0 do 240 km/h
      double simulatedTemperature = Random().nextDouble() * 160; // Temperatura od 0 do 160°C
      double simulatedFuelConsumption = Random().nextDouble() * 50; // Spalanie od 0 do 20 L/100km
      double simulatedRPM = Random().nextDouble() * 10000; // RPM od 0 do 10,000

      // Przekazywanie danych do strumieni
      _speedController.add(simulatedSpeed);
      _temperatureController.add(simulatedTemperature);
      _fuelConsumptionController.add(simulatedFuelConsumption);
      _rpmController.add(simulatedRPM);
    });
  }

  void stopDataCollection() {
    _dataCollectionTimer?.cancel();
  }

  void dispose() {
    _speedController.close();
    _temperatureController.close();
    _fuelConsumptionController.close();
    _rpmController.close();
  }
}
