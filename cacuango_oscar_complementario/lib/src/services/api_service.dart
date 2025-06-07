import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/estudiante.dart';
import '../models/estudiante_login.dart';

class ApiService {
  final String _baseUrl = "http://192.168.1.20:8000";

  Future<Map<String, dynamic>> login(String cedula, String password) async {
    final url = Uri.parse('$_baseUrl/api/token/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cedula': cedula, 'password': password}),
      );
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseBody['access']);
        return {'Success': true, 'message': 'Inicio de sesión exitoso'};
      } else {
        return {
          'Success': false,
          'message': responseBody['error'] ?? 'Error de inicio de sesión',
        };
      }
    } catch (e) {
      return {'Success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> register(EstudianteLogin estudianteLogin) async {
    final url = Uri.parse('$_baseUrl/api/auth/register/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(estudianteLogin.toJson()),
      );
      final responseBody = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'Success': true, 'message': responseBody['message']};
      } else {
        return {
          'success': false,
          'message': responseBody['error'] ?? 'Error de registro',
          'errors': responseBody
        };
      }
    } catch (e) {
      return {'Success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (includeAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<List<Estudiante>> getEstudiantes() async {
    final url = Uri.parse(
        '$_baseUrl/api/estudiantes/'); // Asegúrate que esta ruta coincida con tu backend Django
    try {
      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Estudiante.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load students: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener estudiantes: $e');
    }
  }

  Future<Estudiante> getEstudianteByCedula(String cedula) async {
    final url = Uri.parse(
        '$_baseUrl/api/estudiantes/$cedula/'); // Asegúrate que esta ruta coincida con tu backend Django (lookup_field='cedula')
    try {
      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Estudiante.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Estudiante con cédula $cedula no encontrado');
      } else {
        throw Exception(
            'Failed to load student: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener estudiante: $e');
    }
  }

  Future<Estudiante> createEstudiante(Estudiante estudiante) async {
    final url =
        Uri.parse('$_baseUrl/estudiantes/'); // Asegúrate que esta ruta coincida
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode(estudiante.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Estudiante.fromJson(data);
      } else {
        throw Exception(
            'Failed to create student: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al crear estudiante: $e');
    }
  }

  Future<Estudiante> updateEstudiante(
      String cedula, Estudiante estudiante) async {
    final url = Uri.parse(
        '$_baseUrl/api/estudiantes/$cedula/'); // Asegúrate que esta ruta coincida
    try {
      final response = await http.patch(
        url,
        headers: await _getHeaders(),
        body: json.encode(estudiante.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Estudiante.fromJson(data);
      } else {
        throw Exception(
            'Failed to update student: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al actualizar estudiante: $e');
    }
  }

  Future<void> deleteEstudiante(String cedula) async {
    final url = Uri.parse('$_baseUrl/api/estudiantes/$cedula/');
    try {
      final response = await http.delete(url, headers: await _getHeaders());

      if (response.statusCode != 204) {
        throw Exception(
            'Failed to delete student: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al eliminar estudiante: $e');
    }
  }
}
