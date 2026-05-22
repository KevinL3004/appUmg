class MisAsignacionesModel {
  final int id;
  final String status;
  final String assignedAt;
  final String expectedReturnAt;
  final String? returnedAt;
  final Asset asset;

  MisAsignacionesModel({
    required this.id,
    required this.status,
    required this.assignedAt,
    required this.expectedReturnAt,
    this.returnedAt,
    required this.asset,
  });

  factory MisAsignacionesModel.fromMap(Map<String, dynamic> json) {
    return MisAsignacionesModel(
      id: json['id'],
      status: json['status'] ?? '',
      assignedAt: json['assignedAt'] ?? '',
      expectedReturnAt: json['expectedReturnAt'] ?? '',
      returnedAt: json['returnedAt'],
      asset: Asset.fromMap(json['asset']),
    );
  }
}

class Asset {
  final int id;
  final String assetCode;
  final String name;
  final String serialNumber;
  final double acquisitionCost;
  final String location;
  final String status;

  Asset({
    required this.id,
    required this.assetCode,
    required this.name,
    required this.serialNumber,
    required this.acquisitionCost,
    required this.location,
    required this.status,
  });

  factory Asset.fromMap(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      assetCode: json['assetCode'] ?? '',
      name: json['name'] ?? '',
      serialNumber: json['serialNumber'] ?? '',
      acquisitionCost:
          (json['acquisitionCost'] as num?)?.toDouble() ?? 0,
      location: json['location'] ?? '',
      status: json['status'] ?? '',
    );
  }
}