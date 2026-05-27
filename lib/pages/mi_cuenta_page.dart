import 'package:flutter/material.dart';

class MiCuentaPage extends StatelessWidget {
  const MiCuentaPage({super.key});

  void editarMisDatos(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Editar mis datos pendiente de implementar'),
      ),
    );
  }

  void gestionarUsuarios(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gestión de usuarios pendiente de implementar'),
      ),
    );
  }

  void cerrarSesion(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cerrar sesión pendiente de implementar'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bool esAdmin = true;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  child: const Icon(
                    Icons.person,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Adrián',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'admin',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'usuario@email.com',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar mis datos'),
                subtitle: const Text('Modificar email o contraseña'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => editarMisDatos(context),
              ),
              if (esAdmin) const Divider(height: 1),
              if (esAdmin)
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text('Gestionar usuarios'),
                  subtitle: const Text('Alta, edición y baja de usuarios'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => gestionarUsuarios(context),
                ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesión'),
                subtitle: const Text('Salir de la aplicación'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => cerrarSesion(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}