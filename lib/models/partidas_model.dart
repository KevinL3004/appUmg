import 'dart:convert';

List<PartidasModel> partidasModelFromMap(String str) =>
    List<PartidasModel>.from(
      json.decode(str).map((x) => PartidasModel.fromMap(x)),
    );

class PartidasModel {
  int id;
  String code;
  String description;
  double allocatedAmount;

  PartidasModel({
    required this.id,
    required this.code,
    required this.description,
    required this.allocatedAmount,
  });

  factory PartidasModel.fromMap(Map<String, dynamic> json) => PartidasModel(
    id: json["id"],
    code: json["code"] ?? '',
    description: json["description"] ?? '',
    allocatedAmount: (json["allocatedAmount"] as num).toDouble(),
  );
}