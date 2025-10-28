import 'package:flutter/material.dart';
import 'package:ruteaflutter/theme.dart';

class CustomDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onMenuItemSelected;
  final String userName;
  final String userEmail;

  const CustomDrawer({
    super.key,
    required this.currentIndex,
    required this.onMenuItemSelected,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 🔹 Encabezado del usuario
          Container(
            color: AppTheme.primaryColor,
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  userName.isNotEmpty ? userName : 'Usuario',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userEmail.isNotEmpty ? userEmail : 'correo@ejemplo.com',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 38,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          _buildMenuItem(Icons.alt_route, 'Planificador de rutas', context, 0),
          _buildMenuItem(Icons.list_alt, 'Mostrar líneas', context, 1),
          _buildMenuItem(Icons.receipt_long, 'Tarifas', context, 2),
          _buildMenuItem(Icons.location_on, 'Lugares recientes', context, 3),
          _buildMenuItem(Icons.chat_bubble_outline, 'Comentarios', context, 4),
          _buildMenuItem(Icons.group, 'Gestion de Usuarios', context, 5),
          _buildMenuItem(Icons.info_outline, 'Sobre nosotros', context, 6),

          const Divider(indent: 16, endIndent: 16),

          _buildMenuItem(Icons.share, 'Redes Sociales', context, 6),
          _buildMenuItem(Icons.settings, 'Configuraciones', context, 7),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    BuildContext context,
    int index,
  ) {
    final isSelected = currentIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? AppTheme.primaryColor
            : AppTheme.primaryColor.withValues(alpha: 0.6),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF0A3148),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFF1E90FF).withValues(alpha: 0.1),
      onTap: () {
        Navigator.pop(context);
        onMenuItemSelected(index);
      },
    );
  }
}
