import 'package:lvtn_admin/Models/InforPosition.dart';
import 'package:lvtn_admin/Models/Room.dart';
import 'package:lvtn_admin/Models/offsetPosition.dart';
import 'package:lvtn_admin/Services/roomService.dart';
import 'package:flutter/foundation.dart';

class RoomManager with ChangeNotifier {
  List<Room> _rooms = [];
  List<Room> _search = [];
  Room? _searchRoom;
  Room _userRoom = Room(
      name: 'Vị trí của bạn',
      offset: OffsetPosition(x: 0, y: 0),
      luotTruyCap: 0,
      keyWord: []);

  final RoomService _roomService;

  RoomManager() : _roomService = RoomService();

  Future<void> initilize() async {
    await _roomService.connectDB();
  }

  Future<void> fetchPositions() async {
    _rooms = await _roomService.fetchPositions();
    notifyListeners();
  }

  Future<void> addRoom(Room room) async {
    final newRoom = await _roomService.addRoom(room);
    if (newRoom != null) {
      _rooms = newRoom;
      notifyListeners();
    }
  }

  Future<void> updateRoom(Room room) async {
    await _roomService.updateRoom(room);
    await fetchPositions();
    notifyListeners();
  }

  Future<void> deleteRoom(Room room) async {
    await _roomService.deleteRoom(room);
    await fetchPositions();
    notifyListeners();
  }

  // Future<void> addPosition(InforPosition infor) async {
  //   await _roomService.addPosition(infor, _location);
  //   await fetchPositions();
  //   notifyListeners();
  // }

  // Future<void> deletePosition(InforPosition infor) async {
  //   await _roomService.deletePosition(infor, _location);
  //   await fetchPositions();
  //   notifyListeners();
  // }

  // Future<void> deletePosition(String id) async {
  //   final index = _room.indexWhere((item) => item.id == id);
  //   Position? existingPosition = _room[index];
  //   _room.removeAt(index);
  //   notifyListeners();

  //   if (!await _roomService.deletePosition(id)) {
  //     _room.insert(index, existingPosition);
  //     notifyListeners();
  //   }
  // }
  void setUserRoom(Room room) {
    _userRoom = room;
    notifyListeners();
  }

  Room? get userRoom {
    return _userRoom;
  }

  void setSearchRoom(Room? room) {
    _searchRoom = room!;
    notifyListeners();
  }

  Room? get searchRoom {
    return _searchRoom;
  }

  List<Room>? get rooms {
    return _rooms;
  }

  List<Room> get search {
    _search = [..._rooms];
    _search.sort((a, b) => b.luotTruyCap.compareTo(a.luotTruyCap));
    print(_search[0].name);
    return _search;
  }
}
