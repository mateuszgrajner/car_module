import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'error_home_screen.dart'; // Importujemy ekran odczytu błędów

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
        '/error': (context) => const ErrorHomeScreen(color: const Color.fromARGB(255, 174, 159, 44)),
        // TODO: Dodaj kolejne trasy dla przyszłych ekranów
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
