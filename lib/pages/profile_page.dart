import 'package:flutter/material.dart';
import '../login_page.dart';
import '../Services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final authService = AuthService();

    // Mostrar diálogo de confirmación
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Llamar al logout del backend
      final result = await authService.logout();

      if (context.mounted) {
        // Cerrar el diálogo de carga
        Navigator.pop(context);

        // Mostrar mensaje
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.orange,
          ),
        );

        // Navegar a login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header del perfil
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Usuario Demo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'usuario@ejemplo.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Perfil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Sección de configuración
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuración',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildSettingsItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Información Personal',
                  subtitle: 'Actualiza tus datos',
                  onTap: () {},
                ),
                _buildSettingsItem(
                  context,
                  icon: Icons.lock_outline,
                  title: 'Seguridad',
                  subtitle: 'Cambiar contraseña',
                  onTap: () {},
                ),
                _buildSettingsItem(
                  context,
                  icon: Icons.language,
                  title: 'Idioma',
                  subtitle: 'Español',
                  onTap: () {},
                ),

                const SizedBox(height: 24),
                Text(
                  'Acerca de',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildSettingsItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Ayuda y Soporte',
                  subtitle: 'FAQ y contacto',
                  onTap: () {},
                ),
                _buildSettingsItem(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacidad',
                  subtitle: 'Política de privacidad',
                  onTap: () {},
                ),
                _buildSettingsItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'Acerca de',
                  subtitle: 'Versión 1.0.0',
                  onTap: () {},
                ),

                const SizedBox(height: 24),

                // Botón de cerrar sesión con funcionalidad
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
