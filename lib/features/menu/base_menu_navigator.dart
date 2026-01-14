import 'package:flutter/material.dart';
import 'package:ruteaflutter/core/storage/user_storage.dart';
import 'package:ruteaflutter/features/create-lineas/registro_linea_wizard.dart';
import 'package:ruteaflutter/features/map/presentation/map_presentation.dart';
import 'package:ruteaflutter/features/menu/base_menu_screen.dart';
import 'package:ruteaflutter/features/menu/drawer_menu_item.dart';

class BaseMenuNavigator extends StatefulWidget {
  const BaseMenuNavigator({super.key});

  @override
  State<BaseMenuNavigator> createState() => _BaseMenuNavigatorState();
}

class _BaseMenuNavigatorState extends State<BaseMenuNavigator> {
  int _selectedIndex = 0;
  String _userName = '';
  String _userEmail = '';
  bool _isLoading = true;

  final List<Widget> _pages = [];
  final List<String> _titles = [];

  final List<DrawerMenuItem> menuItems = drawerMenuItems;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (!mounted) return;
    try {
      final user = await UserStorage().getUser();

      setState(() {
        _userName = user["persona"]?["nombres"] ?? user["name"] ?? 'Usuario';
        _userEmail = user["email"] ?? user["persona"]?["email"] ?? '';
        _isLoading = false;
      });
      _initializePages();
    } catch (e) {
      setState(() {
        _userName = 'Usuario';
        _userEmail = '';
        _isLoading = false;
      });
      _initializePages();
      debugPrint('Error cargando usuario: $e');
    }
  }

  void _initializePages() {
    _pages.clear();
    _titles.clear();

    for (final item in menuItems) {
      _pages.add(_buildPageForIndex(item.index));
      _titles.add(
        item.index == 0 ? 'Bienvenido ${_userName.toUpperCase()}!' : item.title,
      );
    }
  }

  Widget _buildPageForIndex(int index) {
    switch (index) {
      case 0:
        return const MapPresentation();
      case 1:
        return const RegistroLineaWizard();
      default:
        final item = menuItems.firstWhere((e) => e.index == index);
        return _buildPlaceholderPage(item.title, item.icon);
    }
  }

  Widget _buildPlaceholderPage(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esta sección estará disponible pronto',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _onMenuItemSelected(int index) {
    if (!mounted) return;

    if (index != _selectedIndex && index >= 0 && index < _pages.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BaseMenuScreen(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      topContent: Text(_titles[_selectedIndex]),
      currentIndex: _selectedIndex,
      onMenuItemSelected: _onMenuItemSelected,
      userName: _userName,
      userEmail: _userEmail,
    );
  }
}
