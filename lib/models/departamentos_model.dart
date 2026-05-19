import 'dart:convert';
List<DepartamentosModel> departamentosModelFromMap(String str) => List<DepartamentosModel>.from(json.decode(str).map((x) => DepartamentosModel.fromMap(x)));
String departamentosModelToMap(List<DepartamentosModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));
class DepartamentosModel {
    int id;
    DateTime createdAt;
    DateTime updatedAt;
    String name;
    String costCenterCode;
    DepartamentosModel({
        required this.id,
        required this.createdAt,
        required this.updatedAt,
        required this.name,
        required this.costCenterCode,
    });
    factory DepartamentosModel.fromMap(Map<String, dynamic> json) => DepartamentosModel(
        id: json["id"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        name: json["name"],
        costCenterCode: json["costCenterCode"],
    );
    Map<String, dynamic> toMap() => {
        "id": id,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "name": name,
        "costCenterCode": costCenterCode,
    };
}