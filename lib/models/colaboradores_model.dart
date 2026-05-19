import 'dart:convert';

List<ColaboradoresModel> colaboradoresModelFromMap(String str) =>
    List<ColaboradoresModel>.from(
      json.decode(str).map((x) => ColaboradoresModel.fromMap(x)),
    );

class ColaboradoresModel {
  int id;
  String fullName;
  String email;
  String departmentName;

  ColaboradoresModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.departmentName,
  });

  factory ColaboradoresModel.fromMap(Map<String, dynamic> json) =>
      ColaboradoresModel(
        id: json["id"],
        fullName: json["fullName"] ?? '',
        email: json["email"] ?? '',
        departmentName: json["department"]?["name"] ?? '',
      );
}