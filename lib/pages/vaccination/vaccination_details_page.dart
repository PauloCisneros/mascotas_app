import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/vaccination_model.dart';

class VaccinationDetailsPage extends StatefulWidget {
  const VaccinationDetailsPage({super.key});

  @override
  State<VaccinationDetailsPage> createState() => _VaccinationDetailsPageState();
}

class _VaccinationDetailsPageState extends State<VaccinationDetailsPage> {
  final _dbService = DatabaseService();
  final ScrollController _scrollController = ScrollController();

  List<VaccinationModel> _registros = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    final nuevos = await _dbService.getVaccinations(page: _page, limit: _limit);

    setState(() {
      _registros.addAll(nuevos);
      _isLoading = false;
      _page++;
      if (nuevos.length < _limit) _hasMore = false;
    });
  }

  void _showDetails(VaccinationModel registro) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text("Propietario: ${registro.propietario}", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Cédula: ${registro.cedula}"),
            Text("Teléfono: ${registro.telefono}"),
            const Divider(),
            Text("Mascota: ${registro.mascotaNombre} (${registro.tipo})"),
            Text("Edad: ${registro.edad}"),
            Text("Sexo: ${registro.sexo}"),
            const Divider(),
            Text("Vacuna aplicada: ${registro.vacuna}"),
            Text("Observaciones: ${registro.observaciones}"),
            const Divider(),
            Text("Latitud: ${registro.latitud}"),
            Text("Longitud: ${registro.longitud}"),
            const Divider(),
            Text("Fecha: ${registro.fecha.toLocal()}"),
            const SizedBox(height: 10),
            if (registro.fotoUrl != null && registro.fotoUrl!.isNotEmpty)
              Image.network(registro.fotoUrl!, height: 150, fit: BoxFit.cover),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text("Editar Registro"),
              onPressed: () {
                Navigator.pop(context); // cerrar modal
                Navigator.pushNamed(
                  context,
                  '/vaccination-edit',
                  arguments: registro,
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registros de Vacunación")),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _registros.length + 1,
        itemBuilder: (context, index) {
          if (index < _registros.length) {
            final registro = _registros[index];
            return ListTile(
              title: Text("${registro.mascotaNombre} - ${registro.tipo}"),
              subtitle: Text("Propietario: ${registro.propietario}"),
              trailing: Text(registro.fecha.toLocal().toString().split(' ')[0]),
              onTap: () => _showDetails(registro),
            );
          } else {
            return _isLoading
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
