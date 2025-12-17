import 'package:flutter/material.dart';
// import 'login_page.dart';
// import 'Services/auth_service.dart';
import 'widgets/bottom_nav_bar.dart';
import 'pages/home_page.dart';
import 'pages/transactions_page.dart';
import 'pages/add_transaction_page.dart';
import 'pages/statistics_page.dart';
import 'pages/profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    TransactionsPage(),
    AddTransactionPage(),
    StatisticsPage(),
    ProfilePage(),
  ];

  // final List<String> _titles = const [
  //   'Inicio',
  //   'Transacciones',
  //   'Crear nuevo registro',
  //   'Estadísticas',
  //   'Perfil',
  // ];

  // Future<void> _logout(BuildContext context) async {
  //   final authService = AuthService();

  //   // Mostrar diálogo de confirmación
  //   final shouldLogout = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Cerrar sesión'),
  //       content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: const Text('Cancelar'),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, true),
  //           child: const Text('Cerrar sesión'),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (shouldLogout == true && context.mounted) {
  //     // Mostrar indicador de carga
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) => const Center(child: CircularProgressIndicator()),
  //     );

  //     // Llamar al logout del backend
  //     final result = await authService.logout();

  //     if (context.mounted) {
  //       // Cerrar el diálogo de carga
  //       Navigator.pop(context);

  //       // Mostrar mensaje
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(result['message']),
  //           backgroundColor: result['success'] ? Colors.green : Colors.orange,
  //         ),
  //       );

  //       // Navegar a login
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const LoginPage()),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(_titles[_currentIndex]),
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.notifications_outlined),
      //       onPressed: () {
      //         ScaffoldMessenger.of(
      //           context,
      //         ).showSnackBar(const SnackBar(content: Text('Notificaciones')));
      //       },
      //       tooltip: 'Notificaciones',
      //     ),
      //     IconButton(
      //       icon: const Icon(Icons.logout),
      //       onPressed: () => _logout(context),
      //       tooltip: 'Cerrar sesión',
      //     ),
      //   ],
      // ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
