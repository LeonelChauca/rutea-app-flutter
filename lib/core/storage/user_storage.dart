import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  // Guarda los datos del usuario
  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();

    // Datos directos del usuario
    await prefs.setInt('user_id', user['id']);
    await prefs.setString('user_name', user['name']);
    await prefs.setString('user_email', user['email']);

    final persona = user['persona'];
    if (persona != null) {
      await prefs.setString('persona_nombres', persona['nombres']);
      await prefs.setString('persona_p_apellido', persona['p_apellido']);
      await prefs.setString('persona_s_apellido', persona['s_apellido']);
      await prefs.setString('persona_ci', persona['ci']);
      await prefs.setString('persona_genero', persona['genero']);
      await prefs.setString(
        'persona_fecha_nacimiento',
        persona['fecha_nacimiento'],
      );
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getInt('user_id'),
      'name': prefs.getString('user_name'),
      'email': prefs.getString('user_email'),
      'persona': {
        'nombres': prefs.getString('persona_nombres'),
        'p_apellido': prefs.getString('persona_p_apellido'),
        's_apellido': prefs.getString('persona_s_apellido'),
        'ci': prefs.getString('persona_ci'),
        'genero': prefs.getString('persona_genero'),
        'fecha_nacimiento': prefs.getString('persona_fecha_nacimiento'),
      },
    };
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('persona_nombres');
    await prefs.remove('persona_p_apellido');
    await prefs.remove('persona_s_apellido');
    await prefs.remove('persona_ci');
    await prefs.remove('persona_genero');
    await prefs.remove('persona_fecha_nacimiento');
  }
}
