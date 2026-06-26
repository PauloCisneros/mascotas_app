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
  DateTime _fechaHora = DateTime.now();

  final _propietarioController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _mascotaController = TextEditingController();
  final _edadController = TextEditingController();
  final _vacunaController = TextEditingController();
  final _observacionesController = TextEditingController();

  String _tipoMascota = 'Perro';
  String _sexoMascota = 'Macho';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos, foto y GPS")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final registro = VaccinationModel(
        propietario: _propietarioController.text,
        cedula: _cedulaController.text,
        telefono: _telefonoController.text,
        tipo: _tipoMascota,
        mascotaNombre: _mascotaController.text,
        edad: _edadController.text,
        sexo: _sexoMascota,
        vacuna: _vacunaController.text,
        observaciones: _observacionesController.text,
        latitud: _currentPosition!.latitude,
        longitud: _currentPosition!.longitude,
        fecha: _fechaHora,
      );

      await _dbService.saveVaccination(registro);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registro exitoso")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
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
            TextFormField(
              controller: _propietarioController,
              decoration: const InputDecoration(labelText: "Nombre del Propietario"),
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            TextFormField(
              controller: _cedulaController,
              decoration: const InputDecoration(labelText: "Cédula del Propietario"),
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            TextFormField(
              controller: _telefonoController,
              decoration: const InputDecoration(labelText: "Teléfono"),
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            DropdownButtonFormField(
              value: _tipoMascota,
              items: ['Perro', 'Gato']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _tipoMascota = v!),
              decoration: const InputDecoration(labelText: "Tipo de Mascota"),
            ),
            TextFormField(
              controller: _mascotaController,
              decoration: const InputDecoration(labelText: "Nombre de la Mascota"),
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            TextFormField(
              controller: _edadController,
              decoration: const InputDecoration(labelText: "Edad Aproximada"),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField(
              value: _sexoMascota,
              items: ['Macho', 'Hembra']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _sexoMascota = v!),
              decoration: const InputDecoration(labelText: "Sexo"),
            ),
            TextFormField(
              controller: _vacunaController,
              decoration: const InputDecoration(labelText: "Vacuna Aplicada"),
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            TextFormField(
              controller: _observacionesController,
              decoration: const InputDecoration(labelText: "Observaciones"),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _capturePhoto, child: const Text("Tomar Fotografía")),
            if (_image != null) Image.file(_image!, height: 120),
            ElevatedButton(onPressed: _getCurrentLocation, child: const Text("Capturar GPS")),
            if (_currentPosition != null)
              Text("Ubicación capturada: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}"),
            const SizedBox(height: 10),
            Text("Fecha y hora: ${_fechaHora.toLocal()}"),
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
