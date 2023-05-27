import 'package:ble_ips_example4/Models/InforPosition.dart';
import 'package:ble_ips_example4/Models/Manager/PositionManager.dart';
import 'package:ble_ips_example4/Models/Manager/RoomManager.dart';
import 'package:ble_ips_example4/Models/Room.dart';
import 'package:ble_ips_example4/Models/offsetPosition.dart';
import 'package:ble_ips_example4/direction.dart';
import 'package:ble_ips_example4/helper.dart';
import 'package:ble_ips_example4/trilateration_method.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ble_data.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:zoom_widget/zoom_widget.dart';

class ChooseMap extends StatefulWidget {
  final String location;
  ChooseMap({Key? key, required this.location}) : super(key: key);

  @override
  ChooseMapState createState() => ChooseMapState();
}

class ChooseMapState extends State<ChooseMap>
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
  Offset? offset;

  @override
  void initState() {
    infor = context.read<PositionManager>().positions.infor;

    super.initState();

    //animation duration 1 seconds
    controller = AnimationController(
      duration: const Duration(milliseconds: 300),
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
      // print(i);
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
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Zoom(
              maxZoomHeight: MediaQuery.of(context).size.height,
              maxZoomWidth: 1300,
              backgroundColor: Colors.white,
              initZoom: 0.6,
              child: GestureDetector(
                onTapDown: (details) {
                  setState(() {
                    offset = details.localPosition;
                  });
                },
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
                          centerXList, centerYList, radiusList, tile, offset),
                      // painter: GridPainter(),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .1,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.location == 'search'
                                              ? 'Chọn Điểm Đến'
                                              : 'Chọn Vị Trí Của Bạn',
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Thu phóng bản đồ và nhấn vào vị trí muốn đến để..',
                                          style: TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          offset != null
                                              ? 'Đang chọn: (${offset?.dx.toStringAsFixed(1)}, ${offset?.dy.toStringAsFixed(1)})'
                                              : '',
                                          style: TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.location == 'search'
                            ? context.read<RoomManager>().setSearchRoom(
                                  Room(
                                    maSo: 10,
                                    map: '',
                                    neightbor: {},
                                    name: offset.toString(),
                                    offset: OffsetPosition(
                                        x: offset!.dx, y: offset!.dy),
                                    luotTruyCap: 0,
                                    keyWord: [],
                                  ),
                                )
                            : context.read<RoomManager>().setUserRoom(Room(
                                  maSo: 10,
                                  map: '',
                                  neightbor: {},
                                  name: offset.toString(),
                                  offset: OffsetPosition(
                                      x: offset!.dx, y: offset!.dy),
                                  luotTruyCap: 0,
                                  keyWord: [],
                                ));
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Direction(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 16),
                        child: Text(
                          'OK',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
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
  Offset? offset;
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

  final bleController = Get.put(BLEResult());

  CirclePainter(this.centerXList, this.centerYList, this.radiusList, this.tile,
      this.offset);

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

        // radiusTextPainter.paint(
        //     canvas,
        //     Offset(centerXList[i] * tile,
        //         centerYList[i] * tile - (radius * tile) / 2 - 5));
        // draw a line
        // var p1 = Offset(centerXList[i] * tile, centerYList[i] * tile);
        // var p2 = Offset(
        //     centerXList[i] * tile, centerYList[i] * tile - radiusList[i] * tile);

        // canvas.drawLine(p1, p2, anchorePaint);

        // drawDashedLine(canvas, anchorePaint, centerXList[i] * tile,
        //     centerYList[i] * tile, radius * tile);
      }

      // Path outline = Path()
      //   ..moveTo(100, 100)
      //   ..lineTo(400, 100)
      //   ..lineTo(400, 400)
      //   ..lineTo(100, 400)
      //   ..close();
      // canvas.drawPath(outline, outlinePaint);
      // Path door = Path()
      //   ..moveTo(300, 100)
      //   ..lineTo(300, 150)
      //   ..quadraticBezierTo(250, 140, 250, 100);

      // canvas.drawPath(door, outlinePaint);
      TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);

      // decision max distance
      if (anchorList.length >= 3) {
        for (int i = 0; i < anchorList.length - 1; i++) {
          pointDistance.add(sqrt(
              pow((anchorList[i + 1].centerX - anchorList[0].centerX), 2) +
                  pow((anchorList[i + 1].centerY - anchorList[0].centerY), 2)));
        }
        // print(pointDistance);
        var maxDistance = pointDistance.reduce(max);
        bleController.maxDistance = maxDistance;
        // print(maxDistance);

        anchorList.sort((a, b) => a.radius.compareTo(b.radius));

        var position =
            trilaterationMethod(anchorList, bleController.maxDistance);
        TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
        const iconUser = Icons.location_history;
        textPainter.text = TextSpan(
            text: String.fromCharCode(iconUser.codePoint),
            style: TextStyle(
                fontSize: 30.0,
                fontFamily: iconUser.fontFamily,
                color: Colors.blue[700]));
        textPainter.layout();

        if ((position[0][0] >= 0.0) && (position[1][0] >= 0.0)) {
          textPainter.paint(canvas,
              Offset(position[0][0] * tile - 15, position[1][0] * tile - 15));

          // var positionTextPainter = TextPainter(
          //   text: TextSpan(
          //     text:
          //         '(${position[0][0].toStringAsFixed(2)}, ${position[1][0].toStringAsFixed(2)})',
          //     style: const TextStyle(
          //       color: Colors.black,
          //       fontSize: 10,
          //     ),
          //   ),
          //   textDirection: TextDirection.ltr,
          // );
          // positionTextPainter.layout(
          //   minWidth: 0,
          //   maxWidth: size.width,
          // );

          // positionTextPainter.paint(canvas,
          //     Offset(position[0][0] * 100 - 25, position[1][0] * 100 + 10));
        }
      }
      const iconEnd = Icons.location_on;
      textPainter.text = TextSpan(
          text: String.fromCharCode(iconEnd.codePoint),
          style: TextStyle(
              fontSize: 50.0,
              fontFamily: iconEnd.fontFamily,
              color: Colors.red[800]));
      textPainter.layout();
      offset != null
          ? textPainter.paint(canvas, Offset(offset!.dx - 25, offset!.dy - 50))
          : null;
    }
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
