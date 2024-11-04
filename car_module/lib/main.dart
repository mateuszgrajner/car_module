import 'package:car_module/engine_temp_screen.dart';
import 'package:car_module/fuel_screen.dart';
import 'package:car_module/history_home_screen.dart';
import 'package:car_module/speed_screen.dart';
import 'package:car_module/history_home_screen.dart';

import 'data_home_screen.dart';
import 'engine_rpm_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'error_home_screen.dart'; 
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Module App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/error': (context) => const ErrorHomeScreen(color:  Color.fromARGB(255, 174, 159, 44)),
        '/data_home': (context) => const LiveDataScreen(color:  Color.fromARGB(255, 153, 45, 163)),
        '/rpm_screen': (context) => const EngineRpmScreen(),
        '/temp_screen': (context) => const EngineTempScreen(),
        '/speed_screen': (context) => const VehicleSpeedScreen(),
        '/fuel_screen': (context) => const FuelConsumptionScreen(),
        '/history_home': (context) => const ReadingsHistoryScreen(),
        
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
