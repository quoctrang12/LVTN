import 'package:ble_ips_example4/Models/offsetPosition.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Room {
  final ObjectId? id;
  int maSo;
  int luotTruyCap;
  String name;
  List keyWord;
  Map neightbor;
  OffsetPosition offset;
  String map;

  Room({
    this.id,
    required this.map,
    required this.name,
    required this.offset,
    required this.maSo,
    required this.neightbor,
    required this.luotTruyCap,
    required this.keyWord,
  });

  Map<String, dynamic> toJson() {
    return {
      'map': map,
      'name': name,
      'maSo': maSo,
      'neightbor': neightbor,
      'luotTruyCap': luotTruyCap,
      'offset': offset.toJson(),
      'keyWord': keyWord,
    };
  }

  static Room fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['_id'],
      map: json['map'],
      name: json['name'],
      neightbor: json['neightbor'],
      maSo: json['maSo'],
      luotTruyCap: json['luotTruyCap'],
      keyWord: json['keyWord'],
      offset: OffsetPosition.fromJson(json['offset']),
    );
  }

  Room copyWith({
    ObjectId? id,
    int? maSo,
    int? luotTruyCap,
    String? map,
    String? name,
    OffsetPosition? offset,
    List? keyWord,
    Map? neightbor,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      map: map ?? this.map,
      maSo: maSo ?? this.maSo,
      luotTruyCap: luotTruyCap ?? this.luotTruyCap,
      offset: offset ?? this.offset,
      keyWord: keyWord ?? this.keyWord,
      neightbor: neightbor ?? this.neightbor,
    );
  }
}
