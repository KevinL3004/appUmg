import 'dart:convert';

List<ProveedoresModel> proveedoresModelFromMap(String str) =>
    List<ProveedoresModel>.from(
      json.decode(str).map((x) => ProveedoresModel.fromMap(x)),
    );

class ProveedoresModel {
  int id;
  String name;
  String taxId;
  String email;
  String phone;
  bool active;

  ProveedoresModel({
    required this.id,
    required this.name,
    required this.taxId,
    required this.email,
    required this.phone,
    required this.active,
  });

  factory ProveedoresModel.fromMap(Map<String, dynamic> json) =>
      ProveedoresModel(
        id: json["id"],
        name: json["name"] ?? '',
        taxId: json["taxId"] ?? '',
        email: json["email"] ?? '',
        phone: json["phone"] ?? '',
        active: json["active"] ?? false,
      );
}