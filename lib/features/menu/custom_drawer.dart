import 'package:flutter/material.dart';
import 'package:ruteaflutter/theme.dart';
import 'package:ruteaflutter/features/menu/drawer_menu_item.dart';

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
          _buildUserHeader(context),
          ...drawerMenuItems.map((item) => _buildMenuItem(item, context)),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Container(
      color: AppTheme.primaryColor,
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
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
          const Align(
            alignment: Alignment.centerRight,
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 38, color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(DrawerMenuItem item, BuildContext context) {
    final isSelected = currentIndex == item.index;

    return ListTile(
      leading: Icon(
        item.icon,
        color: isSelected
            ? AppTheme.primaryColor
            // ignore: deprecated_member_use
            : AppTheme.primaryColor.withOpacity(0.6),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          color: const Color(0xFF0A3148),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      // ignore: deprecated_member_use
      selectedTileColor: const Color(0xFF1E90FF).withOpacity(0.1),
      onTap: () {
        Navigator.pop(context);
        onMenuItemSelected(item.index);
      },
    );
  }
}
