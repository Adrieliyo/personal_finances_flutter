import 'package:flutter/material.dart';

class CategoriesStatisticsPage extends StatelessWidget {
  const CategoriesStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas de Categorías'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category, size: 80, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Estadísticas de Categorías',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Distribución de gastos por categoría'),
          ],
        ),
      ),
    );
  }
}
