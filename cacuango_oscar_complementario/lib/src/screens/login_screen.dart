// lib/src/screens/login_screen.dart
import 'package:cacuango_oscar_complementario/src/screens/crud_screen.dart';
import 'package:cacuango_oscar_complementario/src/screens/estudiante_list_screen.dart';
import 'package:cacuango_oscar_complementario/src/services/api_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Clave para el formulario
  bool _isLoading = false; // Estado para el indicador de carga
  String? _errorMessage; // Para mostrar mensajes de error

  @override
  void dispose() {
    _cedulaController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Método para el Login ---
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await _apiService.login(
        _cedulaController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (result['Success']) {
        // Login exitoso, navega a la pantalla de listado de estudiantes
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const StudentListScreen()),
        );
      } else {
        // Login fallido, muestra el mensaje de error
        setState(() {
          _errorMessage = result['message'];
        });
        // Si el error indica que el usuario no existe, dar opción a registrarse
        if (_errorMessage!.contains('Credenciales inválidas') ||
            _errorMessage!.contains('no encontrado')) {
          _showRegistrationOptionDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_errorMessage!)),
          );
        }
      }
    }
  }

  // --- Diálogo para ofrecer opción de registro ---
  void _showRegistrationOptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuario no encontrado'),
        content: const Text(
            'La cédula o contraseña son incorrectas, o el usuario no está registrado. ¿Deseas registrarte?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
              // Navega a la pantalla de registro (CRUD) para un nuevo estudiante
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EstudianteCrudScreen(
                    initialCedula: _cedulaController.text
                        .trim(), // Pasa la cédula para pre-llenar
                    isNewEstudiante: true, // Indica que es un nuevo registro
                  ),
                ),
              );
            },
            child: const Text('Registrarme'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login UIsrael'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logou.jpg', // Reemplaza con tu logo si tienes uno
                  height: 150,
                ),
                const SizedBox(height: 48.0),
                TextFormField(
                  controller: _cedulaController,
                  decoration: const InputDecoration(
                    labelText: 'Cédula',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu cédula';
                    }
                    if (value.length < 10) {
                      // Validación básica de cédula
                      return 'La cédula debe tener al menos 10 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true, // Oculta la contraseña
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    return null;
                  },
                ),
                if (_errorMessage !=
                    null) // Muestra el mensaje de error si existe
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 32.0),
                _isLoading
                    ? const CircularProgressIndicator() // Muestra un spinner si está cargando
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Iniciar Sesión'),
                      ),
                const SizedBox(height: 20),
                // Opción directa para ir a registrarse (alternativa al diálogo)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            EstudianteCrudScreen(isNewEstudiante: true),
                      ),
                    );
                  },
                  child: const Text('¿No tienes cuenta? Regístrate aquí'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
