import 'package:ble_ips_example4/Models/InforPosition.dart';
import 'package:ble_ips_example4/Models/Position.dart';
import 'package:ble_ips_example4/Services/positionService.dart';
import 'package:flutter/foundation.dart';

class PositionManager with ChangeNotifier {
  Position? _position;
  String _location = 'Class';

  final PositionService _positionService;

  PositionManager() : _positionService = PositionService();

  Future<void> initilize() async {
    await _positionService.connectDB();
  }

  Future<void> fetchPositions() async {
    _position = await _positionService.fetchPositions(_location);
    notifyListeners();
  }

  // Future<void> addPosition(Position pet) async {
  //   final newPosition = await _positionService.addPosition(pet);
  //   if (newPosition != null) {
  //     _position.add(newPosition);
  //     notifyListeners();
  //   }
  // }

  Future<void> updatePosition(InforPosition infor) async {
    await _positionService.updatePosition(infor, _location);
    notifyListeners();
  }

  Future<void> addPosition(InforPosition infor) async {
    await _positionService.addPosition(infor, _location);
    await fetchPositions();
    notifyListeners();
  }

  Future<void> deletePosition(InforPosition infor) async {
    await _positionService.deletePosition(infor, _location);
    await fetchPositions();
    notifyListeners();
  }

  // Future<void> deletePosition(String id) async {
  //   final index = _position.indexWhere((item) => item.id == id);
  //   Position? existingPosition = _position[index];
  //   _position.removeAt(index);
  //   notifyListeners();

  //   if (!await _positionService.deletePosition(id)) {
  //     _position.insert(index, existingPosition);
  //     notifyListeners();
  //   }
  // }

  void setLocation(String location) {
    _location = location;
    fetchPositions();
    notifyListeners();
  }

  String get location {
    return _location;
  }

  Position get positions {
    return _position!;
  }
}
