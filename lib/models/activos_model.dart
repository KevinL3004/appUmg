import 'dart:convert';

List<ActivosModel> activosModelFromMap(String str) =>
    List<ActivosModel>.from(
      json.decode(str).map((x) => ActivosModel.fromMap(x)),
    );

class ActivosModel {
  int id;
  String assetCode;
  String name;
  String description;
  String serialNumber;
  String acquisitionDate;
  double acquisitionCost;
  String status;
  String tagType;
  String tagValue;
  String location;
  CurrentCustodian? currentCustodian;

  ActivosModel({
    required this.id,
    required this.assetCode,
    required this.name,
    required this.description,
    required this.serialNumber,
    required this.acquisitionDate,
    required this.acquisitionCost,
    required this.status,
    required this.tagType,
    required this.tagValue,
    required this.location,
    this.currentCustodian,
  });

  factory ActivosModel.fromMap(Map<String, dynamic> json) => ActivosModel(
    id: json["id"],
    assetCode: json["assetCode"] ?? '',
    name: json["name"] ?? '',
    description: json["description"] ?? '',
    serialNumber: json["serialNumber"] ?? '',
    acquisitionDate: json["acquisitionDate"] ?? '',
    acquisitionCost: (json["acquisitionCost"] as num).toDouble(),
    status: json["status"] ?? '',
    tagType: json["tagType"] ?? '',
    tagValue: json["tagValue"] ?? '',
    location: json["location"] ?? '',
    currentCustodian: json["currentCustodian"] == null
        ? null
        : CurrentCustodian.fromMap(json["currentCustodian"]),
  );
}

class CurrentCustodian {
  int id;
  String fullName;
  String email;
  String departmentName;

  CurrentCustodian({
    required this.id,
    required this.fullName,
    required this.email,
    required this.departmentName,
  });

  factory CurrentCustodian.fromMap(Map<String, dynamic> json) =>
      CurrentCustodian(
        id: json["id"],
        fullName: json["fullName"] ?? '',
        email: json["email"] ?? '',
        departmentName: json["department"]?["name"] ?? '',
      );
}