import 'package:flutter/material.dart';

class DebtsStatisticsPage extends StatelessWidget {
  const DebtsStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas de Deudas'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Estadísticas de Deudas',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Control y progreso de tus deudas'),
          ],
        ),
      ),
    );
  }
}
