import 'package:flutter/material.dart';
import '../../models/vaccination_model.dart';
import '../../services/database_service.dart';

class VaccinationEditPage extends StatefulWidget {
  final VaccinationModel registro;
  const VaccinationEditPage({super.key, required this.registro});

  @override
  State<VaccinationEditPage> createState() => _VaccinationEditPageState();
}

class _VaccinationEditPageState extends State<VaccinationEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _dbService = DatabaseService();
  bool _isLoading = false;

  late TextEditingController propietarioController;
  late TextEditingController cedulaController;
  late TextEditingController telefonoController;
  late TextEditingController mascotaController;
  late TextEditingController edadController;
  late TextEditingController vacunaController;
  late TextEditingController observacionesController;
  String tipoMascota = '';
  String sexoMascota = '';

  @override
  void initState() {
    super.initState();
    final r = widget.registro;
    propietarioController = TextEditingController(text: r.propietario);
    cedulaController = TextEditingController(text: r.cedula);
    telefonoController = TextEditingController(text: r.telefono);
    mascotaController = TextEditingController(text: r.mascotaNombre);
    edadController = TextEditingController(text: r.edad);
    vacunaController = TextEditingController(text: r.vacuna);
    observacionesController = TextEditingController(text: r.observaciones);
    tipoMascota = r.tipo;
    sexoMascota = r.sexo;
  }

  Future<void> _updateRecord() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final actualizado = VaccinationModel(
      id: widget.registro.id!,
      propietario: propietarioController.text,
      cedula: cedulaController.text,
      telefono: telefonoController.text,
      mascotaNombre: mascotaController.text,
      edad: edadController.text,
      sexo: sexoMascota,
      vacuna: vacunaController.text,
      observaciones: observacionesController.text,
      tipo: tipoMascota,
      latitud: widget.registro.latitud,
      longitud: widget.registro.longitud,
      fecha: widget.registro.fecha,
      fotoUrl: widget.registro.fotoUrl,
    );

    await _dbService.updateVaccination(actualizado);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registro actualizado")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Vacunación")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: propietarioController, decoration: const InputDecoration(labelText: "Propietario")),
            TextFormField(controller: cedulaController, decoration: const InputDecoration(labelText: "Cédula")),
            TextFormField(controller: telefonoController, decoration: const InputDecoration(labelText: "Teléfono")),
            TextFormField(controller: mascotaController, decoration: const InputDecoration(labelText: "Mascota")),
            TextFormField(controller: edadController, decoration: const InputDecoration(labelText: "Edad")),
            TextFormField(controller: vacunaController, decoration: const InputDecoration(labelText: "Vacuna")),
            TextFormField(controller: observacionesController, decoration: const InputDecoration(labelText: "Observaciones")),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(onPressed: _updateRecord, child: const Text("Guardar Cambios")),
          ],
        ),
      ),
    );
  }
}
