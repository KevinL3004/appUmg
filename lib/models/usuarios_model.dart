import 'dart:convert';

List<UsuariosModel> usuariosModelFromMap(String str) =>
    List<UsuariosModel>.from(
      json.decode(str).map((x) => UsuariosModel.fromMap(x)),
    );

class UsuariosModel {
  int id;
  String username;
  String role;
  int? employeeId;
  String createdAt;

  UsuariosModel({
    required this.id,
    required this.username,
    required this.role,
    this.employeeId,
    required this.createdAt,
  });

  factory UsuariosModel.fromMap(Map<String, dynamic> json) => UsuariosModel(
    id: json["id"],
    username: json["username"] ?? '',
    role: json["role"] ?? '',
    employeeId: json["employeeId"],
    createdAt: json["createdAt"] ?? '',
  );
}