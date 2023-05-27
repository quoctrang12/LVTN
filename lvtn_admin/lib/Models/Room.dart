import 'package:lvtn_admin/Models/offsetPosition.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Room {
  final ObjectId? id;
  int luotTruyCap;
  String name;
  List keyWord;
  OffsetPosition offset;

  Room({
    this.id,
    required this.name,
    required this.offset,
    required this.luotTruyCap,
    required this.keyWord,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'luotTruyCap': luotTruyCap,
      'offset': offset.toJson(),
      'keyWord': keyWord,
    };
  }

  static Room fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['_id'],
      name: json['name'],
      luotTruyCap: json['luotTruyCap'],
      keyWord: json['keyWord'],
      offset: OffsetPosition.fromJson(json['offset']),
    );
  }

  Room copyWith({
    ObjectId? id,
    int? luotTruyCap,
    String? name,
    List? keyWord,
    OffsetPosition? offset,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      luotTruyCap: luotTruyCap ?? this.luotTruyCap,
      offset: offset ?? this.offset,
      keyWord: keyWord ?? this.keyWord,
    );
  }
}
