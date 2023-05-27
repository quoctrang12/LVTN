import 'package:ble_ips_example4/Models/InforPosition.dart';
import 'package:ble_ips_example4/Models/Room.dart';
import 'package:mongo_dart/mongo_dart.dart';

class RoomService {
  RoomService() : super();
  var db;
  Future<void> connectDB() async {
    db = await Db.create(
        'mongodb+srv://quoctrang12:trang12345@cluster0.cckksgh.mongodb.net/LVTN?retryWrites=true&w=majority');
    await db.open();
  }

  Future<List<Room>?> fetchPositions(location) async {
    List<Room> rooms = [];
    try {
      var collection = db.collection('Search');

      await collection.find(where.eq('map', location)).forEach((v) {
        rooms.add(Room.fromJson(v));
      });

      return rooms;
    } catch (error) {
      print(error);
      return rooms;
    }
  }

  Future<bool> updateRoom(Room room) async {
    // print(room.luotTruyCap);
    try {
      var collection = db.collection('Search');
      collection.updateOne(where.eq('_id', room.id),
          modify.set('luotTruyCap', room.luotTruyCap));
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
