import 'package:flutter/material.dart';

class ConnectionStatus extends StatelessWidget {
  const ConnectionStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 218, 219, 223), // Ciemniejsze tło kontenera
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          const Text(
            'Połączenie: brak połączenia',
            style: TextStyle(
              fontSize: 16.0,
              color: Color.fromARGB(255, 0, 0, 0), // Jasny tekst dla ciemnego tła
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // TODO: Akcja połączenia z modułem OBD
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16.0),
            ),
            child: const Text(
              'Połącz',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
