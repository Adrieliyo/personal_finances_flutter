import 'package:flutter/material.dart';

class GoalsStatisticsPage extends StatelessWidget {
  const GoalsStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas de Metas'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Estadísticas de Metas',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Progreso y análisis de tus metas'),
          ],
        ),
      ),
    );
  }
}
