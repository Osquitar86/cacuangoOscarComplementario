import 'package:cacuango_oscar_complementario/src/models/estudiante.dart';
import 'package:cacuango_oscar_complementario/src/models/estudiante_login.dart';
import 'package:cacuango_oscar_complementario/src/screens/estudiante_list_screen.dart';
import 'package:cacuango_oscar_complementario/src/services/api_service.dart';
import 'package:flutter/material.dart';

class EstudianteCrudScreen extends StatefulWidget {
  final String? initialCedula;
  final bool isNewEstudiante;

  const EstudianteCrudScreen({
    super.key,
    this.initialCedula,
    this.isNewEstudiante = true,
  });

  @override
  State<EstudianteCrudScreen> createState() => _EstudianteCrudScreenState();
}

class _EstudianteCrudScreenState extends State<EstudianteCrudScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController(); // Solo para nuevo registro
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _carreraController = TextEditingController();
  final TextEditingController _nivelController = TextEditingController();

  DateTime? _selectedFechaNacimiento;
  String? _selectedGenero;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCedula != null && widget.initialCedula!.isNotEmpty) {
      _cedulaController.text = widget.initialCedula!;
    }

    if (!widget.isNewEstudiante && widget.initialCedula != null) {
      _loadEstudianteData(widget.initialCedula!);
    }
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _passwordController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    _carreraController.dispose();
    _nivelController.dispose();
    super.dispose();
  }

  Future<void> _loadEstudianteData(String cedula) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final estudiante = await ApiService().getEstudianteByCedula(cedula);
      _cedulaController.text = estudiante.cedula;
      _nombresController.text = estudiante.nombres;
      _apellidosController.text = estudiante.apellidos;
      _telefonoController.text = estudiante.telefono;
      _correoController.text = estudiante.correo;
      _direccionController.text = estudiante.direccion;
      _carreraController.text = estudiante.carrera;
      _nivelController.text = estudiante.nivel;
      _selectedFechaNacimiento = estudiante.fechaNacimiento;

      if (['Masculino', 'Femenino', 'Otro'].contains(estudiante.genero)) {
        _selectedGenero = estudiante.genero;
      } else {
        _selectedGenero = null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectedDate(
      BuildContext context, bool isFechaNacimiento) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFechaNacimiento) {
          _selectedFechaNacimiento = picked;
        }
      });
    }
  }

  Future<void> _saveEstudiante() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final estudiante = Estudiante(
        cedula: _cedulaController.text.trim(),
        nombres: _nombresController.text.trim(),
        apellidos: _apellidosController.text.trim(),
        fechaNacimiento: _selectedFechaNacimiento,
        genero: _selectedGenero ?? '',
        correo: _correoController.text.trim(),
        direccion: _direccionController.text.trim(),
        telefono: _telefonoController.text.trim(),
        carrera: _carreraController.text.trim(),
        nivel: _nivelController.text.trim(),
        activo: true,
      );

      try {
        if (widget.isNewEstudiante) {
          if (_passwordController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'La contraseña es obligatoria para nuevos registros')),
            );
            setState(() {
              _isSaving = false;
            });
            return;
          }
          final estudianteLogin = EstudianteLogin(
            cedula: estudiante.cedula,
            password: _passwordController.text.trim(),
            firstName: _nombresController.text.trim(),
            lastName: _apellidosController.text.trim(),
            email: _correoController.text.trim(),
          );

          final loginResult = await _apiService.register(estudianteLogin);
          if (loginResult['Success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loginResult['message'],
                    style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => const EstudianteCrudScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loginResult['message'])),
            );
          }
        } else {
          await _apiService.updateEstudiante(estudiante.cedula, estudiante);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Estudiante actualizado exitosamente')),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar estudiante: $e')),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteEstudiante() async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text(
            '¿Estás seguro de que quieres eliminar a este estudiante? Esta acción es irreversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _apiService.deleteEstudiante(_cedulaController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estudiante eliminado exitosamente')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const StudentListScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar estudiante: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.isNewEstudiante
              ? 'Nuevo Estudiante'
              : 'Editar Estudiante'),
          backgroundColor: Colors.blueAccent,
          actions: [
            if (!widget.isNewEstudiante)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteEstudiante,
                tooltip: 'Eliminar Estudiante',
              ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _cedulaController,
                        decoration: const InputDecoration(labelText: 'Cédula'),
                        validator: (value) {
                          if (widget.isNewEstudiante &&
                              (value == null || value.isEmpty)) {
                            return 'La cédula es obligatoria';
                          }
                          return null;
                        },
                        enabled: widget.isNewEstudiante,
                      ),
                      if (widget.isNewEstudiante)
                        TextFormField(
                          controller: _nombresController,
                          decoration:
                              const InputDecoration(labelText: 'Nombres'),
                          validator: (value) {
                            if (widget.isNewEstudiante &&
                                (value == null || value.isEmpty)) {
                              return 'Los nombres son obligatorios';
                            }
                            return null;
                          },
                        ),
                      if (widget.isNewEstudiante)
                        TextFormField(
                          controller: _apellidosController,
                          decoration:
                              const InputDecoration(labelText: 'Apellidos'),
                          validator: (value) {
                            if (widget.isNewEstudiante &&
                                (value == null || value.isEmpty)) {
                              return 'Los apellidos son obligatorios';
                            }
                            return null;
                          },
                        ),
                      if (widget.isNewEstudiante)
                        TextFormField(
                          controller: _correoController,
                          decoration: const InputDecoration(
                              labelText: 'Correo Electrónico'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (widget.isNewEstudiante &&
                                (value == null || value.isEmpty)) {
                              return 'El correo electrónico es obligatorio';
                            } else if (widget.isNewEstudiante &&
                                !RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value!)) {
                              return 'Ingrese un correo electrónico válido';
                            }
                            return null;
                          },
                        ),
                      if (widget.isNewEstudiante)
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            suffixIcon: IconButton(
                              icon: Icon(_passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_passwordVisible,
                          validator: (value) {
                            if (widget.isNewEstudiante &&
                                (value == null || value.isEmpty)) {
                              return 'La contraseña es obligatoria';
                            }
                            return null;
                          },
                        ),
                      if (!widget.isNewEstudiante) ...[
                        TextFormField(
                          controller: _nombresController,
                          decoration:
                              const InputDecoration(labelText: 'Nombres'),
                        ),
                        TextFormField(
                          controller: _apellidosController,
                          decoration:
                              const InputDecoration(labelText: 'Apellidos'),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _telefonoController,
                                decoration: const InputDecoration(
                                    labelText: 'Teléfono'),
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: TextFormField(
                                controller: _correoController,
                                decoration: const InputDecoration(
                                    labelText: 'Correo Electrónico'),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: _direccionController,
                          decoration:
                              const InputDecoration(labelText: 'Dirección'),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _carreraController,
                                decoration:
                                    const InputDecoration(labelText: 'Carrera'),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: TextFormField(
                                controller: _nivelController,
                                decoration:
                                    const InputDecoration(labelText: 'Nivel'),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: TextEditingController(
                                  text: _selectedFechaNacimiento != null
                                      ? _selectedFechaNacimiento!
                                          .toLocal()
                                          .toIso8601String()
                                          .split('T')
                                          .first
                                      : '',
                                ),
                                decoration: const InputDecoration(
                                    labelText: 'Fecha de Nacimiento'),
                                readOnly: true,
                                onTap: () => _selectedDate(context, true),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedGenero,
                                hint: const Text('Género'),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'Masculino',
                                      child: Text('Masculino')),
                                  DropdownMenuItem(
                                      value: 'Femenino',
                                      child: Text('Femenino')),
                                  DropdownMenuItem(
                                      value: 'Otro', child: Text('Otro')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGenero = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24.0),
                      Center(
                        child: _isSaving
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _saveEstudiante,
                                child: Text(widget.isNewEstudiante
                                    ? 'Registrar Estudiante'
                                    : 'Actualizar Estudiante'),
                              ),
                      ),
                    ],
                  ),
                )));
  }
}
