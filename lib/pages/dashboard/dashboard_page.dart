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
  bool _loadingMetrics = true;
  Map<String, dynamic>? _userProfile;
  String? _role;
  String? _sectorNombre;

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
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

    if ((_role == 'coordinador_brigada' || _role == 'vacunador') && _userProfile?['sector_id'] != null) {
      final sectorId = _userProfile!['sector_id'];

      final sector = await _dbService.getSectorById(sectorId);
      final vacunadores = await _dbService.getUsersBySector(sectorId);
      final vacunaciones = await _dbService.getVaccinationsBySector(sectorId);

      setState(() {
        _sectores = 1;
        _brigadistas = 0;
        _vacunadores = vacunadores.length;
        _vacunaciones = vacunaciones.length;
        _sectorNombre = sector?['nombre'] ?? 'Mi Sector';
        _loadingMetrics = false;
      });
    } else {
      // Dashboard general (coordinador campaña)
      final sectores = await _dbService.countSectors();
      final brigadistas = await _dbService.countUsersByRole('coordinador_brigada');
      final vacunadores = await _dbService.countUsersByRole('vacunador');
      final vacunaciones = await _dbService.countVaccinations();

      setState(() {
        _sectores = sectores;
        _brigadistas = brigadistas;
        _vacunadores = vacunadores;
        _vacunaciones = vacunaciones;
        _loadingMetrics = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text(
          (_role == 'coordinador_brigada' || _role == 'vacunador')
              ? "Dashboard de ${_sectorNombre ?? 'Mi Sector'}"
              : "Dashboard Principal",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Recargar métricas",
            onPressed: _fetchMetrics,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar sesión",
            onPressed: _logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Text(
                "${_userProfile?['nombres'] ?? ''} ${_userProfile?['apellidos'] ?? ''}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                "${_userProfile?['email'] ?? ''} • Rol: ${_role ?? 'No detectado'}",
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _userProfile?['nombres'] != null
                      ? _userProfile!['nombres'][0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            // Opciones para Coordinador de campaña
            if (_role == 'coordinador_campana') ...[
              _buildNavButton("Crear Sectores", Icons.map, () {
                Navigator.pushNamed(context, '/sector-management');
              }),
              _buildNavButton("Crear Coordinadores de Brigada", Icons.group_add, () {
                Navigator.pushNamed(
                  context,
                  '/user-management',
                  arguments: {
                    'currentRole': 'coordinador_campana',
                  },
                );
              }),
            ],
            // Opciones para Coordinador de brigada
            if (_role == 'coordinador_brigada') ...[
              _buildNavButton("Crear Vacunadores", Icons.person_add, () {
                final sectorId = _userProfile?['sector_id'];
                if (sectorId != null && sectorId is String && sectorId.isNotEmpty) {
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
                    const SnackBar(content: Text("No tienes un sector asignado")),
                  );
                }
              }),
              _buildNavButton("Asignar/Reasignar Vacunadores", Icons.swap_horiz, () {
                Navigator.pushNamed(context, '/assign-vaccinators');
              }),
              _buildNavButton("Corregir Registros de Vacunación", Icons.edit, () {
                Navigator.pushNamed(context, '/vaccination-corrections');
              }),
            ],
            // Opciones para Vacunador
            if (_role == 'vacunador') ...[
              _buildNavButton("Registrar Nueva Vacunación", Icons.vaccines, () {
                Navigator.pushNamed(context, '/vaccination-form');
              }),
            ],
          ],
        ),
      ),
      body: _loadingMetrics
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildMetricCard(_role == 'coordinador_brigada'? (_sectorNombre ?? 'Mi Sector'): "Sectores",_sectores,Icons.map,Colors.blue,),
                  _buildMetricCard("Coordinadores", _brigadistas, Icons.group, Colors.orange),
                  _buildMetricCard("Vacunadores", _vacunadores, Icons.medical_services, Colors.green),
                  _buildMetricCard("Vacunaciones", _vacunaciones, Icons.vaccines, Colors.purple),
                ],
              ),
            ),
    );
  }

  Widget _buildNavButton(String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildMetricCard(String title, int value, IconData icon, Color color) {
    return SizedBox(
      width: 160,
      height: 140,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
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