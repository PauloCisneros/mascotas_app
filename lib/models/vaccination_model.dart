class VaccinationModel {
  final String? id;
  final String propietario;
  final String cedula;
  final String mascotaNombre;
  final String tipo; // Perro o Gato
  final String? fotoUrl;
  final double latitud;
  final double longitud;

  VaccinationModel({
    this.id,
    required this.propietario,
    required this.cedula,
    required this.mascotaNombre,
    required this.tipo,
    this.fotoUrl,
    required this.latitud,
    required this.longitud,
  });

  // Para enviar datos a Supabase
  Map<String, dynamic> toJson() {
    return {
      'propietario_nombre': propietario,
      'propietario_cedula': cedula,
      'mascota_nombre': mascotaNombre,
      'tipo_mascota': tipo,
      'foto_url': fotoUrl,
      'latitud': latitud,
      'longitud': longitud,
    };
  }
}