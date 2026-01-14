import 'package:flutter/material.dart';

class DrawerMenuItem {
  final IconData icon;
  final String title;
  final int index;

  const DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.index,
  });
}

const List<DrawerMenuItem> drawerMenuItems = [
  DrawerMenuItem(
    icon: Icons.alt_route,
    title: 'Planificador de rutas',
    index: 0,
  ),
  DrawerMenuItem(
    icon: Icons.directions_bus,
    title: 'Líneas de transporte',
    index: 1,
  ),
  DrawerMenuItem(icon: Icons.receipt_long, title: 'Tarifas', index: 2),
  DrawerMenuItem(icon: Icons.location_on, title: 'Lugares recientes', index: 3),
  DrawerMenuItem(
    icon: Icons.chat_bubble_outline,
    title: 'Comentarios',
    index: 4,
  ),
  DrawerMenuItem(icon: Icons.group, title: 'Gestión de Usuarios', index: 5),
  DrawerMenuItem(icon: Icons.info_outline, title: 'Sobre nosotros', index: 6),
  DrawerMenuItem(icon: Icons.share, title: 'Redes Sociales', index: 7),
  DrawerMenuItem(icon: Icons.settings, title: 'Configuraciones', index: 8),
];
