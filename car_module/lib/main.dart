import 'package:car_module/engine_temp_screen.dart';
import 'package:car_module/fuel_screen.dart';
import 'package:car_module/history_home_screen.dart';
import 'package:car_module/settings_home_screen.dart';
import 'package:car_module/speed_screen.dart';
import 'package:car_module/summary_overviev_screen.dart';
import 'package:car_module/bluetooth_connection_screen.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'readings_history_screen.dart';
import 'data_home_screen.dart';
import 'engine_rpm_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'error_home_screen.dart';
import 'package:car_module/error_code_model.dart';
import 'package:car_module/live_data_service.dart';
import 'package:car_module/bluetooth_connection_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Aby mieć pewność, że wszystko jest zainicjalizowane
  await fillDatabaseWithSampleData(); // Inicjalizacja bazy danych z przykładowymi danymi

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final liveDataService = LiveDataService(); // Stworzenie instancji LiveDataService
    final bluetoothService = BluetoothConnectionService(); // Stworzenie instancji BluetoothConnectionService

    return MaterialApp(
      title: 'Car Module App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(bluetoothService: bluetoothService),
        '/error': (context) =>
            const ErrorHomeScreen(color: Color.fromARGB(255, 174, 159, 44)),
        '/data_home': (context) =>
            const LiveDataScreen(color: Color.fromARGB(255, 153, 45, 163)),
        '/rpm_screen': (context) =>
            EngineRpmScreen(liveDataService: liveDataService), // Dodanie LiveDataService
        '/temp_screen': (context) =>
            EngineTempScreen(liveDataService: liveDataService), // Dodanie LiveDataService
        '/speed_screen': (context) =>
            VehicleSpeedScreen(liveDataService: liveDataService), // Dodanie LiveDataService
        '/fuel_screen': (context) =>
            FuelConsumptionScreen(liveDataService: liveDataService), // Dodanie LiveDataService
        '/history_home': (context) => const ReadingsHistoryScreen(),
        '/readings_screen': (context) => const ReadingsLogScreen(),
        '/summary_screen': (context) => const SummaryOverviewScreen(),
        '/settings_screen': (context) => const SettingsScreen(),
        '/bluetooth': (context) =>
            BluetoothConnectionScreen(bluetoothService: bluetoothService),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
