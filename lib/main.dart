// import 'package:flutter/material.dart';
// import 'login_page.dart';
// import 'dashboard_page.dart';
// import 'Services/auth_service.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Personal Finances',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       debugShowCheckedModeBanner: false,
//       home: const AuthCheck(),
//     );
//   }
// }

// class AuthCheck extends StatefulWidget {
//   const AuthCheck({super.key});

//   @override
//   State<AuthCheck> createState() => _AuthCheckState();
// }

// class _AuthCheckState extends State<AuthCheck> {
//   final _authService = AuthService();
//   bool _isChecking = true;
//   bool _isAuthenticated = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkAuthentication();
//   }

//   Future<void> _checkAuthentication() async {
//     final isAuth = await _authService.isAuthenticated();
//     setState(() {
//       _isAuthenticated = isAuth;
//       _isChecking = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isChecking) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return _isAuthenticated ? const DashboardPage() : const LoginPage();
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'Services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Finances',
      debugShowCheckedModeBanner: false,

      // Configuración de localización
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español
        Locale('en', 'US'), // Inglés (opcional)
      ],
      locale: const Locale('es', 'ES'), // Locale por defecto

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthCheck(),
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  final _authService = AuthService();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isAuth = await _authService.isAuthenticated();
    setState(() {
      _isAuthenticated = isAuth;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _isAuthenticated ? const DashboardPage() : const LoginPage();
  }
}
