import 'package:ble_ips_example4/Models/InforPosition.dart';
import 'package:ble_ips_example4/Models/Manager/PositionManager.dart';
import 'package:ble_ips_example4/helper.dart';
import 'package:ble_ips_example4/search_screen.dart';
import 'package:ble_ips_example4/trilateration_method.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ble_data.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:zoom_widget/zoom_widget.dart';

class CircleRoute extends StatefulWidget {
  const CircleRoute({Key? key}) : super(key: key);

  @override
  CircleRouteState createState() => CircleRouteState();
}

class CircleRouteState extends State<CircleRoute>
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
    return Stack(
      children: [
        Zoom(
          maxZoomHeight: MediaQuery.of(context).size.height,
          maxZoomWidth: 1300,
          backgroundColor: Colors.white,
          initZoom: 0.6,
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
                        : context.read<PositionManager>().location == 'Library'
                            ? 'assets/capture (5).png'
                            : 'assets/TangTret.jpg',
                  ),
                ),
              ),
              child: CustomPaint(
                foregroundPainter:
                    CirclePainter(centerXList, centerYList, radiusList, tile),
                // painter: GridPainter(),
              ),
            ),
          ),
        ),
        Positioned(
          child: Container(
            height: 55,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(),
              borderRadius: BorderRadius.circular(28),
            ),
            margin: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tìm kiếm',
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
        ),
      ],
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

  CirclePainter(this.centerXList, this.centerYList, this.radiusList, this.tile);

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
        canvas.drawCircle(Offset(centerXList[i] * tile, centerYList[i] * tile),
            radius * tile, anchorePaint);
        // centerX, centerY
        canvas.drawCircle(Offset(centerXList[i] * tile, centerYList[i] * tile),
            2, anchorePaint);
        // anchor text paint
        var anchorTextPainter = TextPainter(
          text: TextSpan(
            text: 'Anchor$i\n(${centerXList[i]}, ${centerYList[i]})',
            style: const TextStyle(
              color: Colors.black,
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
          if ((position[1][0] >= 2.88) && (position[1][0] <= 9.94)) {
            if ((position[0][0] < 3.35)) {
              position[0][0] = 3.35;
            } else if ((position[0][0] > 4.53)) {
              position[0][0] = 4.53;
            }
          }
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
