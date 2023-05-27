import 'dart:convert';
import 'package:lvtn_admin/Models/InforPosition.dart';
import 'package:lvtn_admin/Models/Position.dart';
import 'package:lvtn_admin/Models/Room.dart';
import 'package:mongo_dart/mongo_dart.dart';

class RoomService {
  RoomService() : super();
  var db;
  Future<void> connectDB() async {
    db = await Db.create(
        'mongodb+srv://quoctrang12:trang12345@cluster0.cckksgh.mongodb.net/LVTN?retryWrites=true&w=majority');
    await db.open();
  }

  Future<List<Room>> fetchPositions() async {
    List<Room> rooms = [];
    try {
      var collection = db.collection('Search');

      await collection.find().forEach((v) {
        rooms.add(Room.fromJson(v));
      });

      return rooms;
    } catch (error) {
      print(error);
      return rooms;
    }
  }

  Future<bool> updateRoom(Room room) async {
    try {
      var collection = db.collection('Search');
      collection.updateOne(
          where.eq('_id', room.id),
          modify
              .set('luotTruyCap', room.luotTruyCap)
              .set('name', room.name)
              .set('offset', room.offset.toJson()));
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> deleteRoom(Room room) async {
    try {
      var collection = db.collection('Search');
      collection.deleteOne(where.eq('_id', room.id));
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<List<Room>?> addRoom(Room room) async {
    try {
      var collection = db.collection('Search');
      var rs = await collection.insertOne(room.toJson());
      if (rs.isSuccess) {
        List<Room> rooms = [];
        await collection.find().forEach((v) {
          rooms.add(Room.fromJson(v));
        });
        return rooms;
      }
      return null;
    } catch (error) {
      print(error);
      return null;
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
