import 'dart:math';

import 'package:ble_ips_example4/Models/Room.dart';
import 'package:ble_ips_example4/Models/offsetPosition.dart';
import 'package:ble_ips_example4/Services/roomService.dart';

import 'package:dijkstra/dijkstra.dart';
import 'package:flutter/material.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

class RoomManager with ChangeNotifier {
  List<Room>? _rooms;
  List<Room>? _search;
  Room? _searchRoom;
  String _location = '';
  Room _userRoom = Room(
      maSo: 0,
      map: '',
      neightbor: {},
      name: '',
      offset: OffsetPosition(x: 0, y: 0),
      luotTruyCap: 0,
      keyWord: []);

  final RoomService _roomService;

  Map<dynamic, dynamic> _graph = {};

  RoomManager() : _roomService = RoomService();

  Future<void> initilize() async {
    await _roomService.connectDB();
  }

  Future<void> fetchPositions(location) async {
    _rooms = await _roomService.fetchPositions(location);
    _graph = {};
    (await _roomService.fetchPositions(location))?.forEach(
      (element) {
        Map neightbor = element.neightbor
            .map((key, value) => MapEntry(int.parse(key), value));
        Map temp = {element.maSo: neightbor};
        _graph.addAll(temp);
      },
    );
    // print(_graph);
    notifyListeners();
  }

  // Future<void> addPosition(Position pet) async {
  //   final newPosition = await _roomService.addPosition(pet);
  //   if (newPosition != null) {
  //     _room.add(newPosition);
  //     notifyListeners();
  //   }
  // }

  Future<void> updateRoom(Room room) async {
    await _roomService.updateRoom(room);
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

  void setLocation(String location) {
    _location = location;
    notifyListeners();
  }

  void setUserRoom(Room room) {
    // print(room.name);
    _userRoom = room;
    notifyListeners();
  }

  Room get userRoom {
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

  List<Room>? get search {
    _search = [..._rooms!.where((element) => element.name != '').toList()];
    _search!.sort((a, b) => b.luotTruyCap.compareTo(a.luotTruyCap));
    // print(_search);
    return _search;
  }

  double distance(Offset a, Offset b) {
    double sum = 0;
    sum = sqrt((a.dx - b.dx) * (a.dx - b.dx) + (a.dy - b.dy) * (a.dy - b.dy));
    if (_location == 'School') return (sum / 20);
    return (sum / 130);
  }

  /// Kiểm tra 2 điểm có nằm trên 1 đường thẳng hay không?
  List<Map>? testTwoPoint(Room first, Room last, List<Room> listRoom) {
    List<Map> path = [];
    // lấy tọa độ của first và last
    var start = Offset(first.offset.x, first.offset.y);
    var end = Offset(last.offset.x, last.offset.y);
    // Khoảng cách từ start đến end
    double span = distance(start, end);
    path.add({
      "title": "Từ ${first.name} đi thẳng ${span.toStringAsFixed(2)} m",
      "icon": Typicons.arrow_up_outline,
    });

    if (start.dx == end.dx || start.dy == end.dy) {
      if (start.dx > end.dx || start.dx < end.dx) {
        return path;
      }
      if (start.dy > end.dy || start.dy < end.dy) {
        return path;
      }
    }
    if (_graph[first.maSo]![last.maSo] != null) {
      return path;
    }
    return null;
  }

  /// Lấy tọa độ điểm mà tại đó đường đi có rẽ hướng
  Room? getPoint(List<Room> listPoint, List<Room> listRoom) {
    for (int i = listPoint.length - 2; i > 0; i--) {
      if (testThreePoint(
              listPoint.first, listPoint[i], listPoint.last, listRoom) !=
          null) {
        return listPoint[i];
      }
    }
    return null;
  }

  /// Kiểm tra 3 điểm có rẽ hướng hay không
  List? testThreePoint(Room first, Room mid, Room last, List<Room> listRoom) {
    var start = Offset(first.offset.x, first.offset.y);
    var prevEnd = Offset(mid.offset.x, mid.offset.y);
    var end = Offset(last.offset.x, last.offset.y);
    // Khoảng cách từ điểm giữa tới điểm cuối
    double span = distance(prevEnd, end);
    List left = [
      {
        "title": "Quẹo trái ${span.toStringAsFixed(2)} m",
        "icon": Typicons.arrow_left_outline
      }
    ];
    List right = [
      {
        "title": "Quẹo phải ${span.toStringAsFixed(2)} m",
        "icon": Typicons.arrow_right_outline
      }
    ];
    // Kiểm tra điểm đầu và điểm giửa có nằm trên 1 đường thẳng hay không
    if (testTwoPoint(first, mid, listRoom) != null) {
      if (start.dy == prevEnd.dy && prevEnd.dx == end.dx ||
          start.dy == prevEnd.dy && testTwoPoint(mid, last, listRoom) != null) {
        if (start.dx > prevEnd.dx) {
          if (prevEnd.dy < end.dy) {
            return left;
          }
          return right;
        } else {
          if (prevEnd.dy < end.dy) {
            return right;
          }
          return left;
        }
      } else if (start.dx == prevEnd.dx && prevEnd.dy == end.dy ||
          start.dx == prevEnd.dx && testTwoPoint(mid, last, listRoom) != null) {
        if (start.dy < prevEnd.dy) {
          if (prevEnd.dx < end.dx) {
            return left;
          }
          return right;
        } else {
          if (prevEnd.dx < end.dx) {
            return right;
          }
          return left;
        }
      }
      if (testTwoPoint(mid, last, listRoom) != null) {
        if (start.dx > prevEnd.dx && prevEnd.dy > end.dy ||
            start.dx < prevEnd.dx && prevEnd.dy < end.dy) {
          return right;
        }
        if (start.dx > prevEnd.dx && prevEnd.dy < end.dy ||
            start.dx < prevEnd.dx && prevEnd.dy > end.dy) {
          return left;
        }
      }
    }
    return null;
  }

  List<Room> dijkstra({required Room from, required Room to}) {
    List<Room> listDijkstra = [];
    List dijkstra = Dijkstra.findPathFromGraph(
        _graph, from.maSo as dynamic, to.maSo as dynamic);
    for (var element in dijkstra) {
      listDijkstra.add(_rooms!.firstWhere((e) => e.maSo == element));
    }
    return listDijkstra;
  }

  /// Hàm tìm đường đi
  List<Map> route(
      {required Room from, required Room to, required List<Room> listRoom}) {
    if (distance(Offset(from.offset.x, from.offset.y),
            Offset(to.offset.x, to.offset.y)) <
        1) {
      return [
        {
          "title": "Đã đến vị trí bạn muốn",
          "icon": Typicons.arrow_up_outline,
        }
      ];
    }
    try {
      List<Room> listDijkstra = dijkstra(from: from, to: to);
      // Nếu mã phòng nhỏ hơn 100 thì chuyển thành tên ngược lại giữ nguyên
      Room roomName = listDijkstra.first;

      List<Map> path = [];
      if (testTwoPoint(listDijkstra.first, listDijkstra.last, listRoom) !=
          null) {
        return testTwoPoint(listDijkstra.first, listDijkstra.last, listRoom)!;
      } else {
        var point = getPoint(listDijkstra, listRoom);
        if (point != null) {
          double span = distance(
              Offset(listDijkstra.first.offset.x, listDijkstra.first.offset.y),
              Offset(point.offset.x, point.offset.y));
          path.add({
            "title":
                "Từ ${roomName.name} đi thẳng ${span.toStringAsFixed(2)} m",
            "icon": Typicons.arrow_up_outline,
          });
          for (var element in testThreePoint(
              listDijkstra.first, point, listDijkstra.last, listRoom)!) {
            path.add(element);
          }
          return path;
        } else {
          List<Room> left = [];
          List<Room> right = [];

          left.addAll(listDijkstra);
          while (getPoint(left, listRoom) == null) {
            left.removeLast();
          }
          right.addAll(listDijkstra.getRange(
              listDijkstra.indexOf(getPoint(left, listRoom)!),
              listDijkstra.length));
          double span = distance(
              Offset(listDijkstra.first.offset.x, listDijkstra.first.offset.y),
              Offset(right.first.offset.x, right.first.offset.y));
          path.add({
            "title":
                "Từ ${roomName.name} đi thẳng ${span.toStringAsFixed(2)} m",
            "icon": Typicons.arrow_up_outline,
          });
          for (var element
              in route(from: left.first, to: left.last, listRoom: listRoom)) {
            if (!element["title"].toString().contains("đi thẳng")) {
              path.add(element);
            }
          }
          for (var element
              in route(from: right.first, to: right.last, listRoom: listRoom)) {
            if (!element["title"].toString().contains("đi thẳng")) {
              path.add(element);
            }
          }
          return path;
        }
      }
    } catch (e) {
      return [
        {
          "title": "Chưa tìm được hướng dẫn",
          "icon": Typicons.arrow_up_outline,
        }
      ];
    }
  }
}



// class ManagerRoom {
//   final Map _graph = {
//     "0": {"1": 130, "2": 70, "12": 55, "13": 180, "30": 140, "31": 222},
//     "1": {
//       "0": 130,
//       "13": 60,
//       "49": 80,
//       "61": 62,
//       "62": 70,
//       "64": 50,
//       "50": 140
//     },
//     "2": {"0": 70, "12": 70, "50": 70, "52": 20, "60": 50, "38": 50},
//     "3": {"37": 40},
//     "4": {"34": 30, "47": 40},
//     "1005": {"31": 62, "34": 80},
//     "2005": {"47": 80, "48": 60},
//     "11": {"12": 93, "35": 45},
//     "12": {"0": 55, "2": 70, "11": 112},
//     "13": {"0": 180, "1": 60, "31": 110},
//     "14": {"32": 20, "110": 62},
//     "15": {"16": 62, "33": 30},
//     "16": {"15": 62, "17": 62},
//     "17": {"16": 62, "18": 62},
//     "18": {"17": 62, "19": 62},
//     "19": {"18": 62, "20": 62, "107": 170},
//     "20": {"19": 62},
//     "21": {"33": 40, "34": 62},
//     "30": {"0": 140, "31": 172, "100": 40, "101": 62, "38": 70},
//     "31": {"1005": 62, "13": 110, "30": 172, "0": 302},
//     "32": {"14": 20, "103": 50, "104": 12},
//     "33": {"15": 30, "21": 40, "111": 42},
//     "34": {"4": 30, "1005": 93, "21": 62},
//     "35": {"11": 45, "36": 80, "100": 20},
//     "36": {"35": 80, "37": 296},
//     "37": {"3": 40, "36": 296},
//     "38": {"30": 70, "2": 50},
//     "100": {"30": 40, "35": 20},
//     "101": {"30": 62, "102": 62},
//     "102": {"101": 62, "103": 62},
//     "103": {"102": 62, "32": 50},
//     "104": {"32": 12, "105": 62},
//     "105": {"104": 62, "106": 62},
//     "106": {"105": 62, "107": 62},
//     "107": {"106": 62, "108": 62, "19": 170},
//     "108": {"107": 62, "109": 62},
//     "109": {"108": 62},
//     "110": {"14": 62, "111": 62},
//     "111": {"110": 62, "33": 42},
//     "40": {"41": 70, "201": 70, "52": 70},
//     "41": {"42": 180, "40": 70},
//     "42": {
//       "202": 40,
//       "41": 180,
//       "43": 140,
//       "51": 180,
//       "208": 180,
//       "206": 160,
//       "44": 200
//     },
//     "43": {
//       "210": 50,
//       "203": 70,
//       "202": 120,
//       "42": 140,
//       "206": 100,
//       "208": 70,
//       "51": 110
//     },
//     "44": {"208": 40, "209": 160, "42": 200},
//     "45": {"213": 122, "46": 70, "212": 40, "47": 80},
//     "46": {"45": 70, "217": 20, "218": 62},
//     "47": {"45": 80, "4": 40, "2005": 80},
//     "48": {"201": 200, "63": 50, "2005": 60},
//     "49": {"63": 50, "62": 20, "61": 60, "1": 80, "64": 20},
//     "50": {"1": 140, "2": 70, "60": 40, "52": 60},
//     "51": {"206": 30, "204": 40, "202": 160, "42": 180, "43": 110},
//     "52": {"2": 20, "40": 70, "60": 40, "50": 60},
//     "60": {"52": 40, "50": 40, "2": 50},
//     "61": {"62": 50, "49": 60, "1": 62, "64": 70},
//     "62": {"49": 20, "61": 50, "1": 70},
//     "63": {"48": 50, "49": 50},
//     "64": {"49": 20, "1": 50, "61": 70},
//     "201": {"40": 70, "48": 200},
//     "202": {"42": 40, "43": 120, "203": 62, "51": 160, "206": 150, "208": 170},
//     "203": {"202": 62, "43": 70, "208": 190, "206": 200},
//     "204": {"202": 200, "51": 40, "205": 124},
//     "205": {"204": 124, "207": 20},
//     "206": {"202": 150, "203": 200, "208": 62, "51": 30, "42": 160, "43": 100},
//     "207": {"205": 20},
//     "208": {"203": 190, "202": 170, "44": 40, "206": 62, "42": 180, "43": 70},
//     "209": {"44": 160},
//     "210": {"211": 62, "43": 50},
//     "211": {"212": 62, "210": 62},
//     "212": {"45": 40, "211": 62},
//     "213": {"214": 124, "45": 122},
//     "214": {"213": 124, "215": 62},
//     "215": {"214": 62, "216": 62},
//     "216": {"215": 62},
//     "217": {"46": 20},
//     "218": {"46": 62, "219": 62},
//     "219": {"218": 62, "220": 62},
//     "220": {"219": 62, "221": 32},
//     "221": {"220": 32},
//   };

//   // 392.7  698.2
//   late Map offset_1 = {
//     0: {"x": 235.700000 * _width - 0.5, "y": 0.871097 * _height - 1},
//     1: {"x": 0.405246 * _width - 0.5, "y": 0.888857 * _height - 1},
//     2: {"x": 0.665190 * _width - 0.5, "y": 0.817817 * _height - 1},
//     3: {"x": 0.892641 * _width - 0.5, "y": 0.496362 * _height - 1},
//     4: {"x": 0.226534 * _width - 0.5, "y": 0.631338 * _height - 1},
//     1005: {"x": 0.307767 * _width - 0.5, "y": 0.711258 * _height - 1},
//     10: {"x": 0.600204 * _width - 0.5, "y": 0.871097 * _height - 1},
//     11: {"x": 0.689559 * _width - 0.5, "y": 0.771641 * _height - 1},
//     12: {"x": 0.689559 * _width - 0.5, "y": 0.871097 * _height - 1},
//     13: {"x": 0.307767 * _width - 0.5, "y": 0.853337 * _height - 1},
//     14: {"x": 0.551464 * _width - 0.5, "y": 0.538098 * _height - 1},
//     15: {"x": 0.307767 * _width - 0.5, "y": 0.528330 * _height - 1},
//     16: {"x": 0.307767 * _width - 0.5, "y": 0.467946 * _height - 1},
//     17: {"x": 0.307767 * _width - 0.5, "y": 0.412890 * _height - 1},
//     18: {"x": 0.307767 * _width - 0.5, "y": 0.357834 * _height - 1},
//     19: {"x": 0.307767 * _width - 0.5, "y": 0.302779 * _height - 1},
//     20: {"x": 0.307767 * _width - 0.5, "y": 0.247723 * _height - 1},
//     21: {"x": 0.307767 * _width - 0.5, "y": 0.578058 * _height - 1},
//     30: {"x": 0.600204 * _width - 0.5, "y": 0.755657 * _height - 1},
//     31: {"x": 0.307767 * _width - 0.5, "y": 0.755657 * _height - 1},
//     32: {"x": 0.600204 * _width - 0.5, "y": 0.538098 * _height - 1},
//     33: {"x": 0.307767 * _width - 0.5, "y": 0.538098 * _height - 1},
//     34: {"x": 0.307767 * _width - 0.5, "y": 0.631338 * _height - 1},
//     35: {"x": 0.689559 * _width - 0.5, "y": 0.755657 * _height - 1},
//     36: {"x": 0.827655 * _width - 0.5, "y": 0.755657 * _height - 1},
//     37: {"x": 0.827655 * _width - 0.5, "y": 0.496362 * _height - 1},
//     38: {"x": 0.600204 * _width - 0.5, "y": 0.817817 * _height - 1},
//     100: {"x": 0.673313 * _width - 0.5, "y": 0.755657 * _height - 1},
//     101: {"x": 0.600204 * _width - 0.5, "y": 0.684618 * _height - 1},
//     102: {"x": 0.600204 * _width - 0.5, "y": 0.629476 * _height - 1},
//     103: {"x": 0.600204 * _width - 0.5, "y": 0.574506 * _height - 1},
//     104: {"x": 0.600204 * _width - 0.5, "y": 0.519736 * _height - 1},
//     105: {"x": 0.600204 * _width - 0.5, "y": 0.464394 * _height - 1},
//     106: {"x": 0.600204 * _width - 0.5, "y": 0.409338 * _height - 1},
//     107: {"x": 0.600204 * _width - 0.5, "y": 0.354282 * _height - 1},
//     108: {"x": 0.600204 * _width - 0.5, "y": 0.299227 * _height - 1},
//     109: {"x": 0.600204 * _width - 0.5, "y": 0.244171 * _height - 1},
//     110: {"x": 0.470232 * _width - 0.5, "y": 0.538098 * _height - 1},
//     111: {"x": 0.372753 * _width - 0.5, "y": 0.538098 * _height - 1},
//   };

//   late Map offset_2 = {
//     1: {"x": 0.405246 * _width - 0.5, "y": 0.895445 * _height - 1},
//     2: {"x": 0.665190 * _width - 0.5, "y": 0.825265 * _height - 1},
//     3: {"x": 0.892641 * _width - 0.5, "y": 0.496362 * _height - 1},
//     4: {"x": 0.215737 * _width - 0.5, "y": 0.630765 * _height - 1},
//     2005: {"x": 0.313216 * _width - 0.5, "y": 0.711258 * _height - 1},
//     40: {"x": 0.724217 * _width - 0.5, "y": 0.760097 * _height - 1},
//     41: {"x": 0.857474 * _width - 0.5, "y": 0.760097 * _height - 1},
//     42: {"x": 0.857474 * _width - 0.5, "y": 0.589659 * _height - 1},
//     43: {"x": 0.638146 * _width - 0.5, "y": 0.536522 * _height - 1},
//     44: {"x": 0.616756 * _width - 0.5, "y": 0.441278 * _height - 1},
//     45: {"x": 0.313216 * _width - 0.5, "y": 0.536522 * _height - 1},
//     46: {"x": 0.163738 * _width - 0.5, "y": 0.536522 * _height - 1},
//     47: {"x": 0.313216 * _width - 0.5, "y": 0.630765 * _height - 1},
//     48: {"x": 0.313216 * _width - 0.5, "y": 0.760097 * _height - 1},
//     49: {"x": 0.313216 * _width - 0.5, "y": 0.840304 * _height - 1},
//     50: {"x": 0.675579 * _width - 0.5, "y": 0.893440 * _height - 1},
//     51: {"x": 0.862338 * _width - 0.5, "y": 0.441278 * _height - 1},
//     52: {"x": 0.724217 * _width - 0.5, "y": 0.825265 * _height - 1},
//     60: {"x": 0.724217 * _width - 0.5, "y": 0.870381 * _height - 1},
//     61: {"x": 0.430099 * _width - 0.5, "y": 0.860355 * _height - 1},
//     62: {"x": 0.378202 * _width - 0.5, "y": 0.840304 * _height - 1},
//     63: {"x": 0.313216 * _width - 0.5, "y": 0.800201 * _height - 1},
//     64: {"x": 0.313216 * _width - 0.5, "y": 0.865368 * _height - 1},
//     100: {"x": 0.386300 * _width - 0.5, "y": 0.755657 * _height - 1},
//     201: {"x": 0.594270 * _width - 0.5, "y": 0.760097 * _height - 1},
//     202: {"x": 0.787624 * _width - 0.5, "y": 0.589659 * _height - 1},
//     203: {"x": 0.686886 * _width - 0.5, "y": 0.589659 * _height - 1},
//     204: {"x": 0.862363 * _width - 0.5, "y": 0.401174 * _height - 1},
//     205: {"x": 0.862363 * _width - 0.5, "y": 0.280865 * _height - 1},
//     206: {"x": 0.787624 * _width - 0.5, "y": 0.441278 * _height - 1},
//     207: {"x": 0.862363 * _width - 0.5, "y": 0.280865 * _height - 1},
//     208: {"x": 0.686886 * _width - 0.5, "y": 0.441278 * _height - 1},
//     209: {"x": 0.616756 * _width - 0.5, "y": 0.283873 * _height - 1},
//     210: {"x": 0.589407 * _width - 0.5, "y": 0.536522 * _height - 1},
//     211: {"x": 0.488668 * _width - 0.5, "y": 0.536522 * _height - 1},
//     212: {"x": 0.387955 * _width - 0.5, "y": 0.536522 * _height - 1},
//     213: {"x": 0.313216 * _width - 0.5, "y": 0.414208 * _height - 1},
//     214: {"x": 0.313216 * _width - 0.5, "y": 0.299914 * _height - 1},
//     215: {"x": 0.313216 * _width - 0.5, "y": 0.237754 * _height - 1},
//     216: {"x": 0.313216 * _width - 0.5, "y": 0.175594 * _height - 1},
//     217: {"x": 0.163738 * _width - 0.5, "y": 0.516471 * _height - 1},
//     218: {"x": 0.163738 * _width - 0.5, "y": 0.454311 * _height - 1},
//     219: {"x": 0.163738 * _width - 0.5, "y": 0.404182 * _height - 1},
//     220: {"x": 0.163738 * _width - 0.5, "y": 0.354053 * _height - 1},
//     221: {"x": 0.163738 * _width - 0.5, "y": 0.323976 * _height - 1},
//   };

//   Map get graph {
//     return _graph;
//   }

//   List<dynamic> dijkstra({int from = 0, required int to}) {
//     var dijkstra = Dijkstra.findPathFromGraph(_graph, from, to);
//     return dijkstra;
//   }

//   int nameToCode(String title) {
//     try {
//       if (title.toLowerCase().startsWith("phong")) {
//         if (title.toLowerCase().startsWith("phong hop")) {
//           switch (title.toLowerCase()) {
//             case "phong hop 1":
//               return 61;
//             case "phong hop 2":
//               return 63;
//             default:
//               return -1;
//           }
//         } else {
//           return int.parse(title.substring(title.indexOf(' ') + 1));
//         }
//       } else {
//         switch (title.toLowerCase()) {
//           case "khoa cong nghe thong tin":
//             return 20;
//           case "khoa tin hoc ung dung":
//             return 19;
//           case "khoa truyen thong da phuong tien":
//             return 19;
//           case "khoa mang may tinh va truyen thong":
//             return 18;
//           case "khoa khoa hoc may tinh":
//             return 17;
//           case "khoa cong nghe phan mem":
//             return 16;
//           case "khoa he thong thong tin":
//             return 15;
//           case "phong ky thuat":
//             return 21;
//           case "nha ve sinh tang 1":
//             return 1005;
//           case "nha ve sinh tang 2":
//             return 2005;
//           case "khong gian sang che":
//             return 13;
//           case "trung tam tin hoc":
//             return 14;
//           case "van phong khoa":
//             return 12;
//           case "thu vien":
//             return 11;
//           case "hoi truong khoa":
//             return 60;
//           case "van phong doan":
//             return 100;
//           case "sanh khoa":
//             return 0;
//           case "phong hop 1":
//             return 61;
//           case "phong hop 2":
//             return 63;
//           case "phong giao vien thinh giang":
//             return 62;
//           case "van phong bcn khoa":
//             return 64;
//           case "cau thang 1":
//             return 1;
//           case "cau thang 2":
//             return 2;
//           case "cau thang 3":
//             return 3;
//           case "cau thang 4":
//             return 4;
//           default:
//             return int.parse(title);
//         }
//       }
//     } catch (e) {
//       return -1;
//     }
//   }

//   String codetoName(int code) {
//     switch (code) {
//       case 20:
//         return "Khoa CNTT";
//       case 19:
//         return "Khoa THUD";
//       case 18:
//         return "Khoa MMT&TT";
//       case 17:
//         return "Khoa KHMT";
//       case 16:
//         return "Khoa CNPM";
//       case 15:
//         return "Khoa HTTT";
//       case 21:
//         return "PKT";
//       case 1005:
//         return "Nhà vệ sinh tầng 1";
//       case 2005:
//         return "Nhà vệ sinh tầng 2";
//       case 13:
//         return "KG Sáng chế";
//       case 14:
//         return "TT Tin học";
//       case 12:
//         return "VPK";
//       case 11:
//         return "Thư viện";
//       case 60:
//         return "Hội trường khoa";
//       case 61:
//         return "Phòng họp 1";
//       case 62:
//         return "Phòng GV thỉnh giảng";
//       case 63:
//         return "Phòng họp 2";
//       case 64:
//         return "Văn phòng BCN khoa";
//       case 100:
//         return "VPD";
//       case 0:
//         return "Sảnh";
//       case 1:
//         return "Cầu Thang 1";
//       case 2:
//         return "Cầu Thang 2";
//       case 3:
//         return "Cầu Thang 3";
//       case 4:
//         return "Cầu Thang 4";
//       default:
//         return "Ngã rẻ";
//     }
//   }

//   List<dynamic> searchRoom({String from = "0", required String to}) {
//     to = TiengViet.parse(to);
//     from = TiengViet.parse(from);
//     return dijkstra(from: nameToCode(from), to: nameToCode(to));
//   }

//   double distance(Offset a, Offset b) {
//     double sum = 0;
//     sum = sqrt((a.dx - b.dx) * (a.dx - b.dx) + (a.dy - b.dy) * (a.dy - b.dy));
//     return (sum / 10.0);
//   }

//   /// Kiểm tra 2 điểm có nằm trên 1 đường thẳng hay không?
//   List? testTwoPoint(int first, int last, Map offset) {
//     List path = [];
//     // lấy tọa độ của first và last
//     var start = Offset(offset[first]["x"], offset[first]["y"]);
//     var end = Offset(offset[last]["x"], offset[last]["y"]);
//     // Khoảng cách từ start đến end
//     double span = distance(start, end);
//     // Nếu mã phòng nhỏ hơn 100 thì chuyển thành tên ngược lại giữ nguyên
//     String roomName = first < 100 ? codetoName(first) : "phòng $first";
//     path.add({
//       "title": "Từ $roomName đi thẳng ${span.toStringAsFixed(2)} m",
//       "icon": Typicons.arrow_up_outline,
//     });

//     if (start.dx == end.dx || start.dy == end.dy) {
//       if (start.dx > end.dx || start.dx < end.dx) {
//         return path;
//       }
//       if (start.dy > end.dy || start.dy < end.dy) {
//         return path;
//       }
//     }
//     if (_graph[first][last] != null) {
//       return path;
//     }
//     return null;
//   }

//   /// Lấy tọa độ điểm mà tại đó đường đi có rẽ hướng
//   dynamic getPoint(List listPoint, Map offset) {
//     for (int i = listPoint.length - 2; i > 0; i--) {
//       if (testThreePoint(
//               listPoint.first, listPoint[i], listPoint.last, offset) !=
//           null) {
//         return listPoint[i];
//       }
//     }
//     return null;
//   }

//   /// Kiểm tra 3 điểm có rẽ hướng hay không
//   List? testThreePoint(int first, int mid, int last, Map offset) {
//     var start = Offset(offset[first]["x"], offset[first]["y"]);
//     var prevEnd = Offset(offset[mid]["x"], offset[mid]["y"]);
//     var end = Offset(offset[last]["x"], offset[last]["y"]);
//     // Khoảng cách từ điểm giữa tới điểm cuối
//     double span = distance(prevEnd, end);
//     List left = [
//       {
//         "title": "Quẹo trái ${span.toStringAsFixed(2)} m",
//         "icon": Typicons.arrow_left_outline
//       }
//     ];
//     List right = [
//       {
//         "title": "Quẹo phải ${span.toStringAsFixed(2)} m",
//         "icon": Typicons.arrow_right_outline
//       }
//     ];
//     // Kiểm tra điểm đầu và điểm giửa có nằm trên 1 đường thẳng hay không
//     if (testTwoPoint(first, mid, offset) != null) {
//       if (start.dy == prevEnd.dy && prevEnd.dx == end.dx ||
//           start.dy == prevEnd.dy && testTwoPoint(mid, last, offset) != null) {
//         if (start.dx > prevEnd.dx) {
//           if (prevEnd.dy < end.dy) {
//             return left;
//           }
//           return right;
//         } else {
//           if (prevEnd.dy < end.dy) {
//             return right;
//           }
//           return left;
//         }
//       } else if (start.dx == prevEnd.dx && prevEnd.dy == end.dy ||
//           start.dx == prevEnd.dx && testTwoPoint(mid, last, offset) != null) {
//         if (start.dy < prevEnd.dy) {
//           if (prevEnd.dx < end.dx) {
//             return left;
//           }
//           return right;
//         } else {
//           if (prevEnd.dx < end.dx) {
//             return right;
//           }
//           return left;
//         }
//       }
//       if (testTwoPoint(mid, last, offset) != null) {
//         if (start.dx > prevEnd.dx && prevEnd.dy > end.dy ||
//             start.dx < prevEnd.dx && prevEnd.dy < end.dy) {
//           return right;
//         }
//         if (start.dx > prevEnd.dx && prevEnd.dy < end.dy ||
//             start.dx < prevEnd.dx && prevEnd.dy > end.dy) {
//           return left;
//         }
//       }
//     }
//     return null;
//   }

//   /// Hàm tìm đường đi
//   List route(List listDijkstra, Map offset) {
//     // Nếu mã phòng nhỏ hơn 100 thì chuyển thành tên ngược lại giữ nguyên
//     String roomName = listDijkstra.first < 100
//         ? codetoName(listDijkstra.first)
//         : "phòng ${listDijkstra.first}";
//     List path = [];
//     try {
//       if (testTwoPoint(listDijkstra.first, listDijkstra.last, offset) != null) {
//         return testTwoPoint(listDijkstra.first, listDijkstra.last, offset)!;
//       } else {
//         var point = getPoint(listDijkstra, offset);
//         if (point != null) {
//           double span = distance(
//               Offset(offset[listDijkstra.first]["x"],
//                   offset[listDijkstra.first]["y"]),
//               Offset(offset[point]["x"], offset[point]["y"]));
//           path.add({
//             "title": "Từ $roomName đi thẳng ${span.toStringAsFixed(2)} m",
//             "icon": Typicons.arrow_up_outline,
//           });
//           for (var element in testThreePoint(
//               listDijkstra.first, point, listDijkstra.last, offset)!) {
//             path.add(element);
//           }
//           return path;
//         } else {
//           List left = [];
//           List right = [];

//           left.addAll(listDijkstra);
//           while (getPoint(left, offset) == null) {
//             left.removeLast();
//           }
//           right.addAll(listDijkstra.getRange(
//               listDijkstra.indexOf(getPoint(left, offset)),
//               listDijkstra.length));
//           double span = distance(
//               Offset(offset[listDijkstra.first]["x"],
//                   offset[listDijkstra.first]["y"]),
//               Offset(offset[right.first]["x"], offset[right.first]["y"]));
//           path.add({
//             "title": "Từ $roomName đi thẳng ${span.toStringAsFixed(2)} m",
//             "icon": Typicons.arrow_up_outline,
//           });
//           for (var element in route(left, offset)) {
//             if (!element["title"].toString().contains("đi thẳng")) {
//               path.add(element);
//             }
//           }
//           for (var element in route(right, offset)) {
//             if (!element["title"].toString().contains("đi thẳng")) {
//               path.add(element);
//             }
//           }
//           return path;
//         }
//       }
//     } catch (e) {
//       return [
//         {
//           "title": "Chưa tìm được hướng dẫn",
//           "icon": Typicons.arrow_up_outline,
//         }
//       ];
//     }
//   }
// }

// // // ${testTwoPoint(start, prevEnd)!},
// void main(List<String> args) {
//   List arr = ManagerRoom(392.7, 698.2).searchRoom(from: "0", to: "21");

//   print(arr.runtimeType);
//   ManagerRoom(392.7, 698.2).offset_2.forEach(
//     (key, value) {
//       print(
//           '$key: { "x":${value["x"] / 392.7} * _width, "y": ${(value["y"] / 698.2)}* _height },\n');
//     },
//   );
//   // for (var i = 0; i < arr.length - 1; i++) {
//   //   print(
//   //       "${arr[i]} - ${arr[i + 1]} : ${ManagerRoom( 392.7 .2)._graph[arr[i]][arr[i + 1]]}");
//   // }
//   // print(ManagerRoom( 392.7 .2).route(arr.first, arr.last, arr, []));
//   print(
//       ManagerRoom(392.7, 698.2).route(arr, ManagerRoom(392.7, 698.2).offset_1));
// }

// // final Map _graph = {
// // Cầu thang
// //     0: {1: 62, 2: 7, 12: 3, 100: 20},
// //     1: {0: 62, 13: 62, },
// //     2: {0: 7, 12: 5, },
// //     3: {},
// //     4: {5: 12, },
// //     5: {13: 15, 4: 12},

// // Phòng cán bộ
// //     10: {},
// //     11: {12: 62, },
// //     12: {0: 3, 11: 62, 2: 5, },
// //     13: {1: 62, 5: 15},
// //     14: {102: 2, 103: 2, 104: 2, 110: 62},
// //     15: {111: 5, 16: 62, },
// //     16: {15: 62, 17: 62,},
// //     17: {16: 62, 18: 62,},
// //     18: {17: 62, 19: 62,},
// //     19: {18: 62, 20: 62,},
// //     20: {19: 62, },
// //     21: {},
// // Tầng trệt
// //     100: {0: 20, 101: 41},
// //     101: {100: 41, 102: 62, },
// //     102: {101: 62, 103: 62, 14: 2},
// //     103: {102: 62, 104: 62, 14: 2},
// //     104: {103: 62, 105: 62, 14: 2},
// //     105: {104: 62, 106: 62,},
// //     106: {105: 62, 107: 62,},
// //     107: {106: 62, 108: 62,},
// //     108: {107: 62, 109: 62,},
// //     109: {108: 62, },
// //     110: {14: 62, 111: 62,},
// //     111: {110: 62, 15: 5},
// // Tầng lầu

// //   };
// // Sảnh: 0
// // Cầu thang 1: 1
// // Cầu thang 2: 2
// // Cầu thang 3: 3
// // Cầu thang 4: 4
// // WC: 5
// // Văn phòng đoàn: 100
// // Hội trường: 10
// // Thư viện: 11
// // Văn phòng khoa: 12
// // Không gian sáng chế: 13
// // Trung tâm tin học: 14
// // Khoa HTTT: 15
// // BM CNPM: 16
// // BM KHMT: 17
// // BM MMT&TT: 18
// // BM THUD: 19
// // BM CNTT: 20
// // PKT: 21
