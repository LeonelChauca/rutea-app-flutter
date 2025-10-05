// ignore_for_file: non_constant_identifier_names

class RegisterRequest {
  final String email;
  final String password;
  final String nombres;
  final String p_apellido;
  final String s_apellido;
  final DateTime fecha_nacimiento;
  final String ci;
  final String genero;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.nombres,
    required this.p_apellido,
    required this.s_apellido,
    required this.fecha_nacimiento,
    required this.ci,
    required this.genero,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'nombres': nombres,
      'p_apellido': p_apellido,
      's_apellido': s_apellido,
      'fecha_nacimiento': fecha_nacimiento.toIso8601String(),
      'ci': ci,
      'genero': genero,
    };
  }
}
