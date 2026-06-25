class UserModel {
  final String id;
  final String email;
  final String rol; // 'coordinador_campana', 'coordinador_brigada', 'vacunador'
  final bool isFirstLogin;

  UserModel({
    required this.id, 
    required this.email, 
    required this.rol,
    required this.isFirstLogin
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'] ?? '',
      rol: json['rol'] ?? 'vacunador',
      isFirstLogin: json['is_first_login'] ?? true,
    );
  }
}