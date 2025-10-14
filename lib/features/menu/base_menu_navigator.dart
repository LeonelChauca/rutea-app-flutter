import 'package:flutter/material.dart';
import 'package:ruteaflutter/core/storage/user_storage.dart';
import 'package:ruteaflutter/features/map/presentation/map_presentation.dart';
import 'package:ruteaflutter/features/menu/base_menu_screen.dart';

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

  // Define todas las páginas del SPA
  final List<Widget> _pages = [];
  final List<String> _titles = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await UserStorage().getUser();
      if (!mounted) return; // Verifica si el widget sigue montado

      setState(() {
        // Intenta diferentes estructuras de datos
        _userName = user["persona"]?["nombres"] ?? user["name"] ?? 'Usuario';
        _userEmail = user["email"] ?? user["persona"]?["email"] ?? '';
        _isLoading = false;
      });
      _initializePages();
    } catch (e) {
      if (!mounted) return; // Verifica si el widget sigue montado

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
    _pages.addAll([
      const MapPresentation(), // 0 - Mapa/Planificador
      _buildPlaceholderPage('Líneas de Transporte', Icons.list_alt), // 1
      _buildPlaceholderPage('Tarifas', Icons.receipt_long), // 2
      _buildPlaceholderPage('Lugares Recientes', Icons.location_on), // 3
      _buildPlaceholderPage('Comentarios', Icons.chat_bubble_outline), // 4
      _buildPlaceholderPage('Sobre Nosotros', Icons.info_outline), // 5
      _buildPlaceholderPage('Redes Sociales', Icons.share), // 6
      _buildPlaceholderPage('Configuraciones', Icons.settings), // 7
    ]);

    _titles.clear();
    _titles.addAll([
      'Bienvenido ${_userName.toUpperCase()}!',
      'Líneas de Transporte',
      'Tarifas',
      'Lugares Recientes',
      'Comentarios',
      'Sobre Nosotros',
      'Redes Sociales',
      'Configuraciones',
    ]);
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
    // Verifica que el widget esté montado antes de actualizar
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages.isNotEmpty ? _pages : [const SizedBox()],
      ),
      topContent: Text(_titles.isNotEmpty ? _titles[_selectedIndex] : ''),
      currentIndex: _selectedIndex,
      onMenuItemSelected: _onMenuItemSelected,
      userName: _userName,
      userEmail: _userEmail,
    );
  }
}
