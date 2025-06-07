// lib/src/screens/sensors_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Importa la librería image_picker
import 'dart:io'; // Para manejar archivos (File)
import 'package:permission_handler/permission_handler.dart'; // Para gestionar permisos (opcional, pero buena práctica)

class SensorsScreen extends StatefulWidget {
  const SensorsScreen({super.key});

  @override
  State<SensorsScreen> createState() => _SensorsScreenState();
}

class _SensorsScreenState extends State<SensorsScreen> {
  File? _image; // Variable para almacenar la imagen tomada
  final ImagePicker _picker = ImagePicker(); // Instancia de ImagePicker

  // --- Método para verificar y solicitar permisos ---
  Future<bool> _requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Permiso de cámara denegado. Por favor, habilítalo en la configuración de la aplicación.')),
      );
      return false;
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Permiso de cámara denegado permanentemente. Abre la configuración para habilitarlo.')),
      );
      openAppSettings(); // Abre la configuración de la aplicación
      return false;
    }
    return false;
  }

  // --- Tomar una foto usando la cámara ---
  Future<void> _takePhoto() async {
    // Primero, verifica los permisos
    bool hasPermission = await _requestCameraPermission();
    if (!hasPermission) return;

    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path); // Guarda la imagen
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto tomada con éxito!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selección de imagen cancelada.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al tomar foto: $e')),
      );
    }
  }

  // --- Seleccionar una imagen de la galería ---
  Future<void> _pickImageFromGallery() async {
    // Para la galería, se necesita permiso de almacenamiento (READ_EXTERNAL_STORAGE en Android)
    // image_picker lo gestiona automáticamente en versiones recientes, pero es bueno saberlo.
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen seleccionada de la galería!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selección de imagen cancelada.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensores y Multimedia'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image == null
                  ? Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Icon(Icons.image,
                          size: 100, color: Colors.grey),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _image!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tomar Foto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Seleccionar de Galería'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
