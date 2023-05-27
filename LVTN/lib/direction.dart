import 'package:ble_ips_example4/Models/InforPosition.dart';
import 'package:ble_ips_example4/Models/Manager/PositionManager.dart';
import 'package:ble_ips_example4/Models/Manager/RoomManager.dart';
import 'package:ble_ips_example4/Models/Room.dart';
import 'package:ble_ips_example4/Models/offsetPosition.dart';
import 'package:ble_ips_example4/helper.dart';
import 'package:ble_ips_example4/search_screen.dart';
import 'package:ble_ips_example4/search_user_screen.dart';
import 'package:ble_ips_example4/trilateration_method.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ble_data.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:zoom_widget/zoom_widget.dart';

class Direction extends StatefulWidget {
  const Direction({Key? key}) : super(key: key);

  @override
  DirectionState createState() => DirectionState();
}

class DirectionState extends State<Direction>
    with SingleTickerProviderStateMixin {
  double waveRadius = 100.0;
  late AnimationController controller;
  var centerXList = [];
  var centerYList = [];
  List<num> radiusList = [];

  var bleController = Get.put(BLEResult());

  String deviceName = '';
  String macAddress = '';
  String rssi = '';
  String serviceUUID = '';
  String manuFactureData = '';
  String tp = '';
  List<InforPosition> infor = [];

  @override
  void initState() {
    super.initState();
    infor = context.read<PositionManager>().positions.infor;
    //animation duration 1 seconds
    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..forward()
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
          // list position anchor
          centerXList = bleController.selectedCenterXList;
          centerYList = bleController.selectedCenterYList;
          // initialize radius list
          radiusList = [];

          for (int i = 0; i < bleController.selectedDistanceList.length; i++) {
            radiusList.add(0.0);
          }
          // rssi to distance
          for (int idx = 0;
              idx < bleController.selectedDistanceList.length;
              idx++) {
            // rssi in device [idx]
            var rssi = bleController
                .scanResultList[bleController.selectedDeviceIdxList[idx]]
                .rssi
                .last;

            // rssi on 1m to device
            var alpha = bleController.selectedRSSI_1mList[idx];
            // the constant for the environmental facto
            var constantN = bleController.selectedConstNList[idx];

            // var distance = rssi * -1;
            var distance = logDistancePathLoss(
                rssi.toDouble(), alpha.toDouble(), constantN.toDouble());

            radiusList[idx] = distance;
          }
        }
      });
    //
  }

  /* log distance path loss model */
  num logDistancePathLoss(double rssi, double alpha, double constantN) {
    // Distance = 10 ^ ((Measured Power - RSSI)/(10 * N))
    return pow(10.0, ((alpha - rssi) / (10 * constantN)));
  }

  void toStringBLE(ScanResult1 r) {
    deviceName = deviceNameCheck(r);
    macAddress = r.device.id.id;
    rssi = r.rssi.last.toStringAsFixed(2).toString();

    serviceUUID = r.advertisementData.serviceUuids
        .toString()
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '');
    manuFactureData = r.advertisementData.manufacturerData
        .toString()
        .replaceAll('{', '')
        .replaceAll('}', '');
    tp = r.advertisementData.txPowerLevel.toString();
  }

  @override
  Widget build(BuildContext context) {
    for (var i = 0; i < bleController.scanResultList.length; i++) {
      toStringBLE(bleController.scanResultList[i]);
      bleController.updateBLEList(
          deviceName: deviceName,
          macAddress: macAddress,
          rssi: rssi,
          serviceUUID: serviceUUID,
          manuFactureData: manuFactureData,
          tp: tp);
      InforPosition? temp =
          infor.firstWhereOrNull((element) => element.macAddress == macAddress);
      if (temp != null) {
        bleController.updateselectedDeviceIdx(
            i, 2, -temp.rssi1M, temp.offset.x, temp.offset.y, 0);
      }
      setState(() {});
    }

    int tile = context.read<PositionManager>().location == 'Class' ? 85 : 62;
    List<Map> listDirection = [];
    try {
      listDirection = context.read<RoomManager>().route(
            from: context.read<RoomManager>().userRoom,
            to: context.read<RoomManager>().searchRoom!,
            listRoom: context.read<RoomManager>().rooms!,
          );
    } catch (e) {
      print(e);
    }
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Zoom(
                maxZoomHeight: MediaQuery.of(context).size.height,
                maxZoomWidth: 1300,
                backgroundColor: Colors.white,
                initZoom: 0.6,
                child: SafeArea(
                  child: Scaffold(
                    backgroundColor: Colors.white,
                    body: Container(
                      width: context.read<PositionManager>().location == 'Class'
                          ? 630
                          : 465,
                      height: 900,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            context.read<PositionManager>().location == 'Class'
                                ? 'assets/capture (4).png'
                                : context.read<PositionManager>().location ==
                                        'Library'
                                    ? 'assets/capture (5).png'
                                    : 'assets/TangTret.jpg',
                          ),
                        ),
                      ),
                      child: CustomPaint(
                        foregroundPainter: CirclePainter(
                            centerXList,
                            centerYList,
                            radiusList,
                            tile,
                            context.read<RoomManager>().searchRoom!,
                            context.read<RoomManager>().userRoom,
                            context),
                        // painter: GridPainter(),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * .15,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey, spreadRadius: 0, blurRadius: 5)
                    ],
                  ),
                  padding: EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.black,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                SizedBox(height: 17),
                                Icon(
                                  Icons.radio_button_checked_outlined,
                                  color: Colors.blue,
                                  size: 17,
                                ),
                                SizedBox(height: 12),
                                Icon(
                                  Icons.more_vert_rounded,
                                  color: Colors.grey,
                                  size: 14,
                                ),
                                SizedBox(height: 12),
                                Icon(
                                  Icons.location_on,
                                  color: Colors.red[800],
                                  size: 17,
                                ),
                              ],
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    height: 45,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      // color: Colors.white,
                                      border: Border.all(
                                        color: Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    margin: const EdgeInsets.all(4.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SearchUserScreen(),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              context
                                                          .read<RoomManager>()
                                                          .userRoom
                                                          .name ==
                                                      ''
                                                  ? 'Vị trí của bạn'
                                                  : context
                                                      .read<RoomManager>()
                                                      .userRoom
                                                      .name,
                                              style: TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          Icon(Icons.search),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 45,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      // color: Colors.white,
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    margin: const EdgeInsets.all(4.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SearchScreen(),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              context
                                                  .read<RoomManager>()
                                                  .searchRoom!
                                                  .name,
                                              style: TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          Icon(Icons.search),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * .82,
                child: Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey, spreadRadius: 0, blurRadius: 5)
                    ],
                  ),
                  child: ListView.builder(
                    itemCount: listDirection.length,
                    itemBuilder: (context, index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            listDirection[index]["icon"],
                            color: Colors.blue,
                            size: 30,
                          ),
                          Text(
                            listDirection[index]["title"],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class CirclePainter extends CustomPainter {
  var centerXList = [];
  var centerYList = [];
  var radiusList = [];
  var tile = 0;
  Room userRoom;
  Room searchRoom;
  BuildContext context;
  var anchorePaint = Paint()
    ..color = Colors.lightBlue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..isAntiAlias = true;

  var positionPaint = Paint()
    ..color = Colors.redAccent
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..isAntiAlias = true;

  final Paint outlinePaint = Paint()
    ..color = Colors.yellow
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final Paint yellowPaint = Paint()
    ..color = Colors.yellow
    ..style = PaintingStyle.stroke
    ..strokeWidth = 9;

  final bleController = Get.put(BLEResult());

  CirclePainter(this.centerXList, this.centerYList, this.radiusList, this.tile,
      this.searchRoom, this.userRoom, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    List<Anchor> anchorList = [];
    List<double> pointDistance = [];

    if (radiusList.isNotEmpty) {
      for (int i = 0; i < radiusList.length; i++) {
        // radius
        var radius = radiusList[i] > bleController.maxDistance
            ? bleController.maxDistance
            : radiusList[i];
        anchorList.add(Anchor(
            centerX: centerXList[i], centerY: centerYList[i], radius: radius));
        // canvas.drawCircle(Offset(centerXList[i] * tile, centerYList[i] * tile),
        //     radius * tile, anchorePaint);
        // // centerX, centerY
        canvas.drawCircle(Offset(centerXList[i] * tile, centerYList[i] * tile),
            2, anchorePaint);
        // anchor text paint
        var anchorTextPainter = TextPainter(
          text: TextSpan(
            text: '\n(${centerXList[i]}, ${centerYList[i]})',
            style: const TextStyle(
              color: Color.fromARGB(255, 14, 173, 236),
              fontSize: 12,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        anchorTextPainter.layout(
          minWidth: 0,
          maxWidth: size.width,
        );
        anchorTextPainter.paint(
            canvas, Offset(centerXList[i] * tile - 27, centerYList[i] * tile));
        // radius text paint
        // var radiusTextPainter = TextPainter(
        //   text: TextSpan(
        //     text: '  ${radius.toStringAsFixed(2)}m',
        //     style: const TextStyle(
        //       color: Colors.black,
        //       fontSize: 10,
        //     ),
        //   ),
        //   textDirection: TextDirection.ltr,
        // );
        // radiusTextPainter.layout(
        //   minWidth: 0,
        //   maxWidth: size.width,
        // );
        // radiusTextPainter.paint(
        //     canvas,
        //     Offset(centerXList[i] * tile,
        //         centerYList[i] * tile - (radius * tile) / 2 - 5));
      }

      if (anchorList.length >= 3) {
        for (int i = 0; i < anchorList.length - 1; i++) {
          pointDistance.add(sqrt(
              pow((anchorList[i + 1].centerX - anchorList[0].centerX), 2) +
                  pow((anchorList[i + 1].centerY - anchorList[0].centerY), 2)));
        }
        var maxDistance = pointDistance.reduce(max);
        bleController.maxDistance = maxDistance;

        anchorList.sort((a, b) => a.radius.compareTo(b.radius));

        var position =
            trilaterationMethod(anchorList, bleController.maxDistance);
        // Giới hạn phạm vi có thể xuất hiện
        // (270,230) (370,230) (...,830)
        // 230<y<830 => 270<x<370
        // y<230

        if ((position[0][0] >= 0.0) && (position[1][0] >= 0.0)) {
          if ((position[1][0] >= 2.88) && (position[1][0] <= 9.94)) {
            if ((position[0][0] < 3.35)) {
              position[0][0] = 3.35;
            } else if ((position[0][0] > 4.5)) {
              position[0][0] = 4.5;
            }
          }
          TextPainter textPainter =
              TextPainter(textDirection: TextDirection.ltr);
          const iconUser = Icons.location_history;
          textPainter.text = TextSpan(
              text: String.fromCharCode(iconUser.codePoint),
              style: TextStyle(
                  fontSize: 30.0,
                  fontFamily: iconUser.fontFamily,
                  color: Colors.blue[700]));
          textPainter.layout();
          textPainter.paint(canvas,
              Offset(position[0][0] * tile - 15, position[1][0] * tile - 15));
          if (userRoom.name == '') {
            context.read<RoomManager>().setUserRoom(userRoom.copyWith(
                offset: OffsetPosition(
                    x: position[0][0] * tile - 15,
                    y: position[1][0] * tile - 15)));
          }
        }
      }
    }

    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    const iconUser = Icons.location_searching;
    textPainter.text = TextSpan(
        text: String.fromCharCode(iconUser.codePoint),
        style: TextStyle(
            fontSize: 30.0,
            fontFamily: iconUser.fontFamily,
            color: Colors.blue[700]));
    textPainter.layout();

    // List<Map> listDirection = context.read<RoomManager>().route(
    //       from: context.read<RoomManager>().userRoom,
    //       to: context.read<RoomManager>().searchRoom!,
    //       listRoom: context.read<RoomManager>().rooms!,
    //     );
    if (userRoom.name != '') {
      try {
        List<Room> listRoom = context.read<RoomManager>().dijkstra(
              from: context.read<RoomManager>().userRoom,
              to: context.read<RoomManager>().searchRoom!,
            );

        Path path = Path()
          ..moveTo(listRoom.first.offset.x, listRoom.first.offset.y);
        listRoom.forEach((e) {
          return path.lineTo(e.offset.x, e.offset.y);
        });
        canvas.drawPath(path, yellowPaint);
        textPainter.paint(
            canvas, Offset(userRoom.offset.x - 15, userRoom.offset.y - 15));
      } catch (e) {
        Path path = Path()
          ..moveTo(userRoom.offset.x + 15, userRoom.offset.y + 15)
          ..lineTo(searchRoom.offset.x, searchRoom.offset.y);

        canvas.drawPath(path, yellowPaint);
        textPainter.paint(canvas, Offset(userRoom.offset.x, userRoom.offset.y));
      }
    } else {
      textPainter.paint(
          canvas, Offset(userRoom.offset.x - 15, userRoom.offset.y - 15));
      Path path = Path()
        ..moveTo(userRoom.offset.x + 15, userRoom.offset.y + 15)
        ..lineTo(searchRoom.offset.x, searchRoom.offset.y);
      canvas.drawPath(path, yellowPaint);
    }

    if (userRoom.name.contains('Offset') &&
        searchRoom.name.contains('Offset')) {
      Path path = Path()
        ..moveTo(userRoom.offset.x + 15, userRoom.offset.y + 15)
        ..lineTo(searchRoom.offset.x, searchRoom.offset.y);

      canvas.drawPath(path, yellowPaint);
    }

    const iconEnd = Icons.location_on;
    textPainter.text = TextSpan(
        text: String.fromCharCode(iconEnd.codePoint),
        style: TextStyle(
            fontSize: 30.0,
            fontFamily: iconEnd.fontFamily,
            color: Colors.red[800]));
    textPainter.layout();
    textPainter.paint(
        canvas, Offset(searchRoom.offset.x - 15, searchRoom.offset.y - 15));
  }

  void drawDashedLine(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius) {
    const int dashWidth = 4;
    const int dashSpace = 3;
    double startY = 0;
    double x = centerX;
    while (startY < radius - 2 - radius * 0.15) {
      // Draw a dash line
      canvas.drawLine(Offset(x, centerY - startY),
          Offset(x, centerY - startY - dashSpace + 5), paint);
      x += 5;
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) {
    return true;
  }
}
