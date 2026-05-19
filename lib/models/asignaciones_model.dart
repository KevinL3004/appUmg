import 'dart:convert';

List<AsignacionesModel> asignacionesModelFromMap(String str) =>
    List<AsignacionesModel>.from(
      json.decode(str).map((x) => AsignacionesModel.fromMap(x)),
    );

class AsignacionesModel {
  int id;
  Asset asset;
  Employee employee;
  String assignedAt;
  String expectedReturnAt;
  String? returnedAt;
  String status;
  String digitalSignature;
  String receiptConfirmation;

  AsignacionesModel({
    required this.id,
    required this.asset,
    required this.employee,
    required this.assignedAt,
    required this.expectedReturnAt,
    this.returnedAt,
    required this.status,
    required this.digitalSignature,
    required this.receiptConfirmation,
  });

  factory AsignacionesModel.fromMap(Map<String, dynamic> json) =>
      AsignacionesModel(
        id: json["id"],
        asset: Asset.fromMap(json["asset"]),
        employee: Employee.fromMap(json["employee"]),
        assignedAt: json["assignedAt"] ?? '',
        expectedReturnAt: json["expectedReturnAt"] ?? '',
        returnedAt: json["returnedAt"],
        status: json["status"] ?? '',
        digitalSignature: json["digitalSignature"] ?? '',
        receiptConfirmation: json["receiptConfirmation"] ?? '',
      );
}

class Asset {
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
  Employee? currentCustodian;

  Asset({
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

  factory Asset.fromMap(Map<String, dynamic> json) => Asset(
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
        : Employee.fromMap(json["currentCustodian"]),
  );
}

class Employee {
  int id;
  String fullName;
  String email;
  Department department;

  Employee({
    required this.id,
    required this.fullName,
    required this.email,
    required this.department,
  });

  factory Employee.fromMap(Map<String, dynamic> json) => Employee(
    id: json["id"],
    fullName: json["fullName"] ?? '',
    email: json["email"] ?? '',
    department: Department.fromMap(json["department"]),
  );
}

class Department {
  int id;
  String name;
  String costCenterCode;

  Department({
    required this.id,
    required this.name,
    required this.costCenterCode,
  });

  factory Department.fromMap(Map<String, dynamic> json) => Department(
    id: json["id"],
    name: json["name"] ?? '',
    costCenterCode: json["costCenterCode"] ?? '',
  );
}