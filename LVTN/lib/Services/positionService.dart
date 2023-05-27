import 'package:ble_ips_example4/Models/InforPosition.dart';
import 'package:ble_ips_example4/Models/Position.dart';
import 'package:mongo_dart/mongo_dart.dart';

class PositionService {
  PositionService() : super();
  var db;
  Future<void> connectDB() async {
    db = await Db.create(
        'mongodb+srv://quoctrang12:trang12345@cluster0.cckksgh.mongodb.net/LVTN?retryWrites=true&w=majority');
    await db.open();
  }

  Future<Position?> fetchPositions(String location) async {
    Position? position;
    try {
      var collection = db.collection('Position');

      await collection.find(where.eq('location', location)).forEach((v) {
        position = Position.fromJson(v);
      });

      return position;
    } catch (error) {
      print(error);
      return position;
    }
  }

  Future<bool> updatePosition(InforPosition infor, String location) async {
    try {
      var collection = db.collection('Position');
      collection.updateOne(
          where.eq('location', location),
          modify
              .set(r'infor.$[element].rssi1M', infor.rssi1M)
              .set(r'infor.$[element].offset.x', infor.offset.x)
              .set(r'infor.$[element].offset.y', infor.offset.y),
          arrayFilters: [
            {
              'element.macAddress': {r'$eq': infor.macAddress}
            }
          ]);

      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> addPosition(InforPosition infor, String location) async {
    try {
      var collection = db.collection('Position');
      collection.updateOne(
          where.eq('location', location), modify.push('infor', infor.toJson()));

      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> deletePosition(InforPosition infor, String location) async {
    try {
      var collection = db.collection('Position');
      collection.updateOne(where.eq('location', location),
          modify.pull('infor', {'macAddress': infor.macAddress}));

      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  // Future<Position?> addPosition(Position pet) async {
  //   try {
  //     final url = Uri.parse('$databaseUrl/position.json?auth=$token');
  //     final response = await http.post(
  //       url,
  //       body: json.encode(
  //         pet.toJson()
  //           ..addAll({
  //             'creatorId': userId,
  //           }),
  //       ),
  //     );

  //     if (response.statusCode != 200) {
  //       throw Exception(json.decode(response.body)['error']);
  //     }

  //     return pet.copyWith(
  //       id: json.decode(response.body)['name'],
  //     );
  //   } catch (error) {
  //     print(error);
  //     return null;
  //   }
  // }

  // Future<bool> deletePosition(String id) async {
  //   try {
  //     final url = Uri.parse('$databaseUrl/position/$id.json?auth=$token');
  //     final response = await http.delete(url);

  //     if (response.statusCode != 200) {
  //       throw Exception(json.decode(response.body)['error']);
  //     }

  //     return true;
  //   } catch (error) {
  //     print(error);
  //     return false;
  //   }
  // }
}
