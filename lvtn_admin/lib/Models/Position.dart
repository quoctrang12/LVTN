import 'package:lvtn_admin/Models/InforPosition.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Position {
  final String location;
  ObjectId? id;
  List<InforPosition> infor;

  Position({
    this.id,
    required this.location,
    required this.infor,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'infor': infor,
    };
  }

  static Position fromJson(Map<String, dynamic> json) {
    List<InforPosition> temp = [];
    json['infor'].forEach((e) {
      temp.add(InforPosition.fromJson(e));
    });
    return Position(
      id: json['_id'],
      location: json['location'],
      infor: temp,
    );
  }

  Position copyWith({
    ObjectId? id,
    String? location,
    List<InforPosition>? infor,
  }) {
    return Position(
      id: id ?? this.id,
      location: location ?? this.location,
      infor: infor ?? this.infor,
    );
  }
}
