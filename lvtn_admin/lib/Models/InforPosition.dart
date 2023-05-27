import 'package:lvtn_admin/Models/offsetPosition.dart';

class InforPosition {
  final int id;
  int rssi1M;
  String macAddress, name;
  OffsetPosition offset;

  InforPosition({
    required this.id,
    required this.name,
    required this.offset,
    required this.rssi1M,
    required this.macAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rssi1M': rssi1M,
      'offset': offset.toJson(),
      'macAddress': macAddress,
    };
  }

  static InforPosition fromJson(Map<String, dynamic> json) {
    return InforPosition(
      id: json['id'],
      name: json['name'],
      rssi1M: json['rssi1M'],
      macAddress: json['macAddress'],
      offset: OffsetPosition.fromJson(json['offset']),
    );
  }

  InforPosition copyWith({
    int? id,
    int? rssi1M,
    String? name,
    String? macAddress,
    OffsetPosition? offset,
  }) {
    return InforPosition(
      id: id ?? this.id,
      name: name ?? this.name,
      rssi1M: rssi1M ?? this.rssi1M,
      offset: offset ?? this.offset,
      macAddress: macAddress ?? this.macAddress,
    );
  }
}
