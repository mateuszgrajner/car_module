import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300.0, // Ustalona szerokość kontenera
        height: 300.0, // Ustalona wysokość kontenera
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.85),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
