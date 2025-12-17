import 'package:flutter/material.dart';

class BudgetsStatisticsPage extends StatelessWidget {
  const BudgetsStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas de Presupuestos'),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart, size: 80, color: Colors.purple),
            const SizedBox(height: 16),
            Text(
              'Estadísticas de Presupuestos',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Seguimiento de tus presupuestos'),
          ],
        ),
      ),
    );
  }
}
