import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _authService = AuthService();
  final _dbService = DatabaseService();

  int _sectores = 0;
  int _brigadistas = 0;
  int _vacunadores = 0;
  int _vacunaciones = 0;
  int _perrosVacunados = 0;
  int _gatosVacunados = 0;

  bool _loadingMetrics = true;

  Map<String, dynamic>? _userProfile;
  String? _role;
  String? _sectorNombre;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _fetchUserProfile() async {
    final profile = await _authService.getUserProfile();
    final role = await _authService.getUserRole();

    setState(() {
      _userProfile = profile;
      _role = role;
    });

    _fetchMetrics();
  }

  Future<void> _fetchMetrics() async {
    setState(() => _loadingMetrics = true);

    try {
      // =========================
      // CAMPAÑA (GLOBAL)
      // =========================
      if (_role == 'coordinador_campana') {
        final sectores = await _dbService.countSectors();
        final brigadistas =
            await _dbService.countUsersByRole('coordinador_brigada');
        final vacunadores =
            await _dbService.countUsersByRole('vacunador');

        final vacunaciones = await _dbService.countVaccinations();
        final perros = await _dbService.countDogsVaccinated();
        final gatos = await _dbService.countCatsVaccinated();

        setState(() {
          _sectores = sectores;
          _brigadistas = brigadistas;
          _vacunadores = vacunadores;
          _vacunaciones = vacunaciones;
          _perrosVacunados = perros;
          _gatosVacunados = gatos;
          _loadingMetrics = false;
        });
      }

      // =========================
      // BRIGADA / VACUNADOR (SECTOR)
      // =========================
      else if (_role == 'coordinador_brigada' ||
          _role == 'vacunador') {
        final sectorId = _userProfile?['sector_id'];

        final sector = await _dbService.getSectorById(sectorId);
        final vacunadores =
            await _dbService.getVaccinatorsBySector(sectorId);

        final vacunaciones =
            await _dbService.countVaccinations(sectorId: sectorId);
        final perros =
            await _dbService.countDogsVaccinated(sectorId: sectorId);
        final gatos =
            await _dbService.countCatsVaccinated(sectorId: sectorId);

        setState(() {
          _sectores = 1;
          _brigadistas = 0;
          _vacunadores = vacunadores.length;
          _vacunaciones = vacunaciones;
          _perrosVacunados = perros;
          _gatosVacunados = gatos;
          _sectorNombre = sector?['nombre'] ?? 'Mi Sector';
          _loadingMetrics = false;
        });
      }
    } catch (e) {
      setState(() => _loadingMetrics = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,

      // =========================
      // APPBAR
      // =========================
      appBar: AppBar(
        title: Text(
          _role == 'coordinador_campana'
              ? "Dashboard General"
              : "Dashboard de ${_sectorNombre ?? 'Mi Sector'}",
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMetrics,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.lightBlueAccent],
                ),
              ),
              accountName: Text(
                "${_userProfile?['nombres'] ?? ''} ${_userProfile?['apellidos'] ?? ''}",
              ),
              accountEmail: Text(
                "${_userProfile?['email'] ?? ''} • Rol: ${_role ?? ''}",
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _userProfile?['nombres'] != null
                      ? _userProfile!['nombres'][0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 24, color: Colors.blue),
                ),
              ),
            ),
            if (_role == 'coordinador_campana') ...[
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text("Crear Sectores"),
                onTap: () {
                  Navigator.pushNamed(context, '/sector-management');
                },
              ),
              ListTile(
                leading: const Icon(Icons.group_add),
                title: const Text("Crear Coordinadores de Brigada"),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/user-management',
                    arguments: {
                      'currentRole': 'coordinador_campana',
                    },
                  );
                },
              ),
            ],
            if (_role == 'coordinador_brigada') ...[
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text("Crear Vacunadores"),
                onTap: () {
                  final sectorId = _userProfile?['sector_id'];

                  if (sectorId != null && sectorId.isNotEmpty) {
                    Navigator.pushNamed(
                      context,
                      '/user-management',
                      arguments: {
                        'currentRole': 'coordinador_brigada',
                        'sectorId': sectorId,
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("No tienes un sector asignado"),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: const Text("Asignar/Reasignar Vacunadores"),
                onTap: () {
                  Navigator.pushNamed(context, '/assign-vaccinators');
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text("Ver Registros de Vacunación"),
                onTap: () {
                  Navigator.pushNamed(context, '/vaccination-details');
                },
              ),
            ],
            if (_role == 'vacunador') ...[
              ListTile(
                leading: const Icon(Icons.vaccines),
                title: const Text("Registrar Vacunación"),
                onTap: () {
                  Navigator.pushNamed(context, '/vaccination-form');
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text("Mis Registros"),
                onTap: () {
                  Navigator.pushNamed(context, '/vaccination-details');
                },
              ),
            ],

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Cerrar sesión"),
              onTap: _logout,
            ),
          ],
        ),
      ),

      // =========================
      // BODY
      // =========================
      body: _loadingMetrics
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  if (_role == 'coordinador_campana') ...[
                    _buildCard("Sectores", _sectores, Colors.blue, Icons.map),
                    _buildCard("Coordinadores", _brigadistas, Colors.orange, Icons.group_add),
                    _buildCard("Vacunadores", _vacunadores, Colors.green, Icons.person_add),
                    _buildCard("Vacunaciones", _vacunaciones, Colors.purple, Icons.medical_services),
                    _buildCard("Perros", _perrosVacunados, Colors.brown, Icons.pets),
                    _buildCard("Gatos", _gatosVacunados, Colors.orange, Icons.pets),
                  ],

                  if (_role != 'coordinador_campana') ...[
                    _buildCard("Vacunadores", _vacunadores, Colors.green, Icons.person_add),
                    _buildCard("Vacunaciones", _vacunaciones, Colors.purple, Icons.medical_services),
                    _buildCard("Perros", _perrosVacunados, Colors.brown, Icons.pets),
                    _buildCard("Gatos", _gatosVacunados, Colors.orange, Icons.pets),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildCard(
    String title,
    int value,
    Color color,
    IconData icon,
  ) {
    return SizedBox(
      width: 160,
      height: 140,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.9),
                color.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}