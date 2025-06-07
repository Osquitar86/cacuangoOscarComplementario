class EstudianteLogin {
  final String cedula;
  final String password;
  final String firstName;
  final String lastName;
  final String email;

  EstudianteLogin({
    required this.cedula,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory EstudianteLogin.fromJson(Map<String, dynamic> json) {
    return EstudianteLogin(
      cedula: json['cedula'] as String,
      password: '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cedula': cedula,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
    };
  }
}
