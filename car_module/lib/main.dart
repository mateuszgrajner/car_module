import 'package:car_module/screens/engine_temp_screen.dart';
import 'package:car_module/screens/fuel_screen.dart';
import 'package:car_module/screens/history_home_screen.dart';
import 'package:car_module/screens/settings_home_screen.dart';
import 'package:car_module/screens/speed_screen.dart';
import 'package:car_module/screens/summary_overviev_screen.dart';
import 'package:car_module/screens/bluetooth_connection_screen.dart';
import 'screens/readings_history_screen.dart';
import 'screens/data_home_screen.dart';
import 'screens/engine_rpm_screen.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/error_home_screen.dart';
import 'package:car_module/helpers/error_code_model.dart';
import 'package:car_module/logic/live_data_service.dart';
import 'package:car_module/logic/bluetooth_connection_service.dart';

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
