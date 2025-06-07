// lib/src/screens/student_list_screen.dart
import 'package:cacuango_oscar_complementario/src/models/estudiante.dart';
import 'package:cacuango_oscar_complementario/src/screens/crud_screen.dart';
import 'package:cacuango_oscar_complementario/src/screens/login_screen.dart';
import 'package:cacuango_oscar_complementario/src/screens/sensors_screen.dart';
import 'package:cacuango_oscar_complementario/src/services/api_service.dart';
import 'package:flutter/material.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Estudiante>> _studentsFuture; // Para cargar los estudiantes
  bool _showTable = false; // Alternar entre ListView y DataTable

  @override
  void initState() {
    super.initState();
    _fetchStudents(); // Carga inicial de estudiantes
  }

  // --- Método para obtener la lista de estudiantes ---
  Future<void> _fetchStudents() async {
    setState(() {
      _studentsFuture = _apiService.getEstudiantes();
    });
  }

  // --- Diálogo de confirmación para cerrar sesión ---
  Future<void> _showLogoutConfirmationDialog() async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar tu sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Aquí podrías limpiar Shared Preferences si guardas token/sesión
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.clear(); // O await prefs.remove('jwt_token');

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false, // Elimina todas las rutas anteriores
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estudiantes UIsrael'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(_showTable ? Icons.list : Icons.table_chart),
            onPressed: () {
              setState(() {
                _showTable =
                    !_showTable; // Alternar entre vista de lista y tabla
              });
            },
            tooltip: _showTable ? 'Mostrar como Lista' : 'Mostrar como Tabla',
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt), // Icono para sensores
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SensorsScreen()),
              );
            },
            tooltip: 'Sensores (Cámara/Mapa)',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutConfirmationDialog,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      // FutureBuilder para manejar el estado de la carga de datos
      body: FutureBuilder<List<Estudiante>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error al cargar estudiantes: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay estudiantes registrados.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                                builder: (context) => EstudianteCrudScreen(
                                    isNewEstudiante: true)),
                          )
                          .then((_) => _fetchStudents()); // Refrescar al volver
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar Nuevo Estudiante'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          } else {
            final List<Estudiante> estudiantes = snapshot.data!;
            if (_showTable) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DataTable(
                      columns: const [
                        DataColumn(
                            label: Text('Cédula',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Nombres',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Apellidos',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Correo',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Carrera',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Nivel',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Teléfono',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Dirección',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Género',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Fecha Nac.',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Fecha Ing.',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Activo',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Acción',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: estudiantes.map((student) {
                        return DataRow(cells: [
                          DataCell(Text(student.cedula)),
                          DataCell(Text(student.nombres)),
                          DataCell(Text(student.apellidos)),
                          DataCell(Text(student.correo)),
                          DataCell(Text(student.carrera ?? 'N/A')),
                          DataCell(Text(student.nivel ?? 'N/A')),
                          DataCell(Text(student.telefono ?? 'N/A')),
                          DataCell(Text(student.direccion ?? 'N/A')),
                          DataCell(Text(student.genero ?? 'N/A')),
                          DataCell(Text(student.fechaNacimiento
                                  ?.toLocal()
                                  .toString()
                                  .split(' ')[0] ??
                              'N/A')),
                          DataCell(Text(student.fechaRegistro
                                  ?.toLocal()
                                  .toString()
                                  .split(' ')[0] ??
                              'N/A')),
                          DataCell(Icon(
                              student.activo == true
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: student.activo == true
                                  ? Colors.green
                                  : Colors.red)),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => EstudianteCrudScreen(
                                      initialCedula: student.cedula,
                                      isNewEstudiante: false, // Es una edición
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  // Si hubo cambios, refrescar
                                  _fetchStudents();
                                }
                              },
                              tooltip: 'Editar',
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: estudiantes.length,
                itemBuilder: (context, index) {
                  final student = estudiantes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          student.nombres[0],
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        '${student.nombres} ${student.apellidos}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Cédula: ${student.cedula}'),
                          Text('Correo: ${student.correo}'),
                          Text('Carrera: ${student.carrera ?? 'N/A'}'),
                          Text('Nivel: ${student.nivel ?? 'N/A'}'),
                          // Puedes añadir más detalles aquí si lo deseas
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EstudianteCrudScreen(
                                initialCedula: student.cedula,
                                isNewEstudiante: false, // Es una edición
                              ),
                            ),
                          );
                          if (result == true) {
                            // Si hubo cambios en la edición, refrescar
                            _fetchStudents();
                          }
                        },
                        tooltip: 'Editar',
                      ),
                      onTap: () async {
                        // También puedes permitir la edición al tocar el ListTile
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EstudianteCrudScreen(
                              initialCedula: student.cedula,
                              isNewEstudiante: false,
                            ),
                          ),
                        );
                        if (result == true) {
                          _fetchStudents();
                        }
                      },
                    ),
                  );
                },
              );
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) =>
                    const EstudianteCrudScreen(isNewEstudiante: true)),
          );
          if (result == true) {
            // Refrescar la lista si se añadió un nuevo estudiante
            _fetchStudents();
          }
        },
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        tooltip: 'Registrar Nuevo Estudiante',
        child: const Icon(Icons.add),
      ),
    );
  }
}
