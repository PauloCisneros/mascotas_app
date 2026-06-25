import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/vaccination_model.dart';
import '../../services/database_service.dart';

class VaccinationFormPage extends StatefulWidget {
  const VaccinationFormPage({super.key});

  @override
  State<VaccinationFormPage> createState() => _VaccinationFormPageState();
}

class _VaccinationFormPageState extends State<VaccinationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _dbService = DatabaseService();
  bool _isLoading = false;
  
  File? _image;
  Position? _currentPosition;

  final _propietarioController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _mascotaController = TextEditingController();
  String _tipoMascota = 'Perro'; // Valor por defecto

  Future<void> _capturePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;
    Position position = await Geolocator.getCurrentPosition();
    setState(() => _currentPosition = position);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _image == null || _currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Completa todos los campos, foto y GPS")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final registro = VaccinationModel(
        propietario: _propietarioController.text,
        cedula: _cedulaController.text,
        mascotaNombre: _mascotaController.text,
        tipo: _tipoMascota,
        latitud: _currentPosition!.latitude,
        longitud: _currentPosition!.longitude,
      );

      await _dbService.saveVaccination(registro);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registro exitoso")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Vacunación")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _propietarioController, decoration: const InputDecoration(labelText: "Propietario"), validator: (v) => v!.isEmpty ? 'Requerido' : null),
            TextFormField(controller: _cedulaController, decoration: const InputDecoration(labelText: "Cédula")),
            TextFormField(controller: _mascotaController, decoration: const InputDecoration(labelText: "Nombre Mascota")),
            DropdownButtonFormField(
              value: _tipoMascota,
              items: ['Perro', 'Gato'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _tipoMascota = v!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _capturePhoto, child: const Text("Tomar Foto")),
            if (_image != null) Image.file(_image!, height: 100),
            ElevatedButton(onPressed: _getCurrentLocation, child: const Text("Capturar GPS")),
            if (_currentPosition != null) Text("Ubicación capturada correctamente"),
            const SizedBox(height: 20),
            _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(onPressed: _submitForm, child: const Text("Guardar Registro")),
          ],
        ),
      ),
    );
  }
}