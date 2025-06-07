class Estudiante {
  final int? id;
  final String cedula;
  final String nombres;
  final String apellidos;
  final DateTime? fechaNacimiento;
  final String genero;
  final String correo;
  final String direccion;
  final String telefono;
  final String carrera;
  final String nivel;
  final DateTime? fechaRegistro;
  final bool? activo;

  Estudiante({
    this.id = 0,
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    this.fechaNacimiento,
    required this.genero,
    required this.correo,
    required this.direccion,
    required this.telefono,
    required this.carrera,
    required this.nivel,
    this.fechaRegistro,
    this.activo,
  });

  factory Estudiante.fromJson(Map<String, dynamic> json) {
    return Estudiante(
      id: json['id'] as int?,
      cedula: json['cedula'] as String,
      nombres: json['nombres'] as String? ?? '',
      apellidos: json['apellidos'] as String? ?? '',
      fechaNacimiento:
          json['fecha_nacimiento'] != null && json['fecha_nacimiento'] != ''
              ? DateTime.parse(json['fecha_nacimiento'])
              : null,
      genero: json['genero'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
      direccion: json['direccion'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      carrera: json['carrera'] as String? ?? '',
      nivel: json['nivel'] as String? ?? '',
      fechaRegistro:
          json['fecha_registro'] != null && json['fecha_registro'] != ''
              ? DateTime.parse(json['fecha_registro'])
              : null,
      activo: json['activo'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cedula': cedula,
      'nombres': nombres,
      'apellidos': apellidos,
      'fecha_nacimiento': fechaNacimiento?.toIso8601String().split('T').first,
      'genero': genero,
      'correo': correo,
      'direccion': direccion,
      'telefono': telefono,
      'carrera': carrera,
      'nivel': nivel,
      'fecha_registro': fechaRegistro?.toIso8601String().split('T').first,
      'activo': activo,
    };
  }
}
