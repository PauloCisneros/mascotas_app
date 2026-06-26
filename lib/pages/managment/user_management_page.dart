import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/user_model.dart';

class UserManagementPage extends StatefulWidget {
  final String currentRole;
  final String? sectorId; // null para coordinador de campaña

  const UserManagementPage({
    super.key,
    required this.currentRole,
    this.sectorId,
  });

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final _dbService = DatabaseService();

  final _emailController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _telefonoController = TextEditingController();

  bool _isLoading = false;
  List<UserModel> _usuarios = [];
  List<Map<String, dynamic>> _sectores = [];

  @override
  void initState() {
    super.initState();
    _fetchUsuarios();
    _fetchSectores();
  }

  Future<void> _fetchUsuarios() async {
    if (widget.currentRole == 'coordinador_brigada' && widget.sectorId != null) {
      // brigadista ve SOLO vacunadores de su sector
      final response = await _dbService.getVaccinatorsBySector(widget.sectorId!);
      setState(() {
        _usuarios = response.map((e) => UserModel.fromJson(e)).toList();
      });
    } else if (widget.currentRole == 'coordinador_campana') {
      // campaña ve todos los brigadistas
      final response = await _dbService.getUsersByRole('coordinador_brigada');
      setState(() {
        _usuarios = response.map((e) => UserModel.fromJson(e)).toList();
      });
    }
}

  Future<void> _fetchSectores() async {
    final response = await _dbService.getSectors();
    setState(() {
      _sectores = response;
    });
  }

  Future<void> _crearUsuario() async {
    if (_emailController.text.trim().isEmpty ||
        _cedulaController.text.trim().isEmpty ||
        _nombresController.text.trim().isEmpty ||
        _apellidosController.text.trim().isEmpty ||
        _telefonoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      String nuevoRol;
      String? sectorAsignado;

      if (widget.currentRole == 'coordinador_campana') {
        nuevoRol = 'coordinador_brigada';
        sectorAsignado = null; // campaña crea brigadistas sin sector
      } else if (widget.currentRole == 'coordinador_brigada') {
        nuevoRol = 'vacunador';
        sectorAsignado = widget.sectorId!;
      } else {
        throw Exception("Este rol no puede crear usuarios");
      }

      await _dbService.createUser(
        _emailController.text.trim(),
        'Ecuador2026',
        nuevoRol,
        sectorAsignado ?? '',
        cedula: _cedulaController.text.trim(),
        nombres: _nombresController.text.trim(),
        apellidos: _apellidosController.text.trim(),
        telefono: _telefonoController.text.trim(),
      );

      _emailController.clear();
      _cedulaController.clear();
      _nombresController.clear();
      _apellidosController.clear();
      _telefonoController.clear();

      await _fetchUsuarios();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Usuario $nuevoRol creado exitosamente")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _asignarSector(String userId, String sectorId) async {
    await _dbService.updateUserSector(userId, sectorId);
    await _fetchUsuarios();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sector asignado correctamente")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Usuarios")),
      body: Column(
        children: [
          if (widget.currentRole != 'vacunador')
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Correo electrónico")),
                  TextField(controller: _cedulaController, decoration: const InputDecoration(labelText: "Cédula")),
                  TextField(controller: _nombresController, decoration: const InputDecoration(labelText: "Nombres")),
                  TextField(controller: _apellidosController, decoration: const InputDecoration(labelText: "Apellidos")),
                  TextField(controller: _telefonoController, decoration: const InputDecoration(labelText: "Teléfono")),
                  const SizedBox(height: 10),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _crearUsuario,
                          child: const Text("Crear Usuario"),
                        ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _usuarios.length,
              itemBuilder: (context, index) {
                final user = _usuarios[index];
                return ListTile(
                  title: Text(user.email),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Rol: ${user.rol}"),
                      if (widget.currentRole == 'coordinador_campana' && user.rol == 'coordinador_brigada')
                        DropdownButton<String>(
                          value: user.sectorId?.toString(),
                          hint: const Text("Asignar sector"),
                          items: _sectores.map((sector) {
                            return DropdownMenuItem<String>(
                              value: sector['id'].toString(),
                              child: Text(sector['nombre']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _asignarSector(user.id, value);
                            }
                          },
                        ),
                    ],
                  ),
                  trailing: user.isFirstLogin
                      ? const Icon(Icons.lock_reset, color: Colors.orange)
                      : const Icon(Icons.check_circle, color: Colors.green),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
