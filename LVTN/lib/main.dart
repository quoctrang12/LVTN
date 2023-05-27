import 'dart:math';
import 'package:ble_ips_example4/Models/Manager/PositionManager.dart';
import 'package:ble_ips_example4/Models/Manager/RoomManager.dart';
import 'package:ble_ips_example4/Models/Room.dart';
import 'package:ble_ips_example4/Models/offsetPosition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:simple_kalman/simple_kalman.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

import 'animation_paint.dart';
import 'ble_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) {
            return PositionManager();
          },
        ),
        ChangeNotifierProvider(
          create: (ctx) {
            return RoomManager();
          },
        ),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BLE Indoor Position',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const BLEProjectPage(title: 'BLE Indoor Position'),
      ),
    );
  }
}

/* First Page */
class BLEProjectPage extends StatefulWidget {
  const BLEProjectPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<BLEProjectPage> createState() => _BLEProjectPageState();
}

class _BLEProjectPageState extends State<BLEProjectPage> {
  var bleController = Get.put(BLEResult());

  // page bleController
  final _pageController = PageController();
  TextEditingController textController = TextEditingController();

  // flutter_blue_plus
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  bool isScanning = false;
  late Future<void> _fetchPositions;

  @override
  void initState() {
    _fetchPositions = context.read<PositionManager>().initilize().then((value) {
      context.read<PositionManager>().fetchPositions();
    });
    super.initState();
  }

  /* start or stop callback */
  void toggleState() {
    context.read<PositionManager>().fetchPositions();
    isScanning = !isScanning;
    if (isScanning) {
      flutterBlue.startScan(
        scanMode: ScanMode(2),
        allowDuplicates: true,
        // withServices: [Guid('0000ffe0-0000-1000-8000-00805f9b34fb')],
      );
      scan();
    } else {
      flutterBlue.stopScan();

      bleController.initBLEList();
    }
    setState(() {});
  }

  /* Scan */
  void scan() async {
    flutterBlue.scanResults.listen((results) {
      for (var element in results) {
        if (element.device.name.isNotEmpty) {
          var i =
              bleController.macAddressScanList.indexOf(element.device.id.id);
          if (i != -1) {
            if (bleController.scanResultList[i].rssi.length >= 5) {
              // double mean = bleController
              //     .averageRSSI(bleController.scanResultList[i].rssi);
              // if (mean - element.rssi < 20) {
              //   double variance = bleController.scanResultList[i].rssi
              //           .map((x) => pow(x - mean, 2))
              //           .reduce((a, b) => a + b) /
              //       bleController.scanResultList[i].rssi.length;

              //   double standardDeviation = sqrt(variance);
              //   double errorMeasure = standardDeviation;

              //   double errorEstimate = element.rssi - mean;
              //   SimpleKalman kalmanFilter = SimpleKalman(
              //     errorMeasure: errorMeasure,
              //     errorEstimate: errorEstimate,
              //     q: 0.1,
              //   );
              //   for (var e in bleController.scanResultList[i].rssi) {
              //     kalmanFilter.filtered(e);
              //   }
              //   double newValue = kalmanFilter.filtered(element.rssi * 1.0);
              //   bleController.scanResultList[i].rssi.removeAt(0);

                // if (!newValue.isNaN && newValue != 0) {
                //   bleController.scanResultList[i].rssi.add(newValue);
                // } else {
                  bleController.scanResultList[i].rssi.add(element.rssi * 1.0);
                // }
              // }
            } else {
              bleController.scanResultList[i].rssi.add(element.rssi * 1.0);
            }
          } else {
            ScanResult1 rs = ScanResult1(
                device: element.device,
                advertisementData: element.advertisementData,
                rssi: [element.rssi * 1.0]);
            bleController.scanResultList.add(rs);
            bleController.macAddressScanList.add(element.device.id.id);
          }
        }
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(
                isScanning ? Icons.stop_outlined : Icons.play_arrow_outlined),
            onPressed: toggleState,
          )
        ],
      ),
      body: FutureBuilder(
        future: _fetchPositions,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                isScanning ? CircleRoute() : startScan(),
                // const CircleRoute(),
              ]);
        },
      ),
    );
  }

  Widget startScan() => Center(
        child: Column(
          children: <Widget>[
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FlutterLogo(
                  size: 40,
                ),
                TextAnimator(
                  'Tìm Thiết Bị BLE Xung Quanh',
                  atRestEffect:
                      WidgetRestingEffects.pulse(effectStrength: 0.25),
                  style: Theme.of(context).textTheme.headline6,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.all(8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Chọn bản đồ: ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  width: 150,
                  child: Center(
                    child: DropdownButton<String>(
                        items: <DropdownMenuItem<String>>[
                          DropdownMenuItem<String>(
                            value: 'Class',
                            child: Text('Phòng học'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Library',
                            child: Text('Thư viện trường'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'School',
                            child: Text('Trường CNTT & TT'),
                          ),
                        ],
                        value: context.read<PositionManager>().location,
                        onChanged: (value) {
                          setState(() {
                            context.read<PositionManager>().setLocation(value!);
                            context.read<RoomManager>().setLocation(value);
                            context.read<RoomManager>().setUserRoom(
                                  Room(
                                    maSo: 0,
                                    map: '',
                                    neightbor: {},
                                    name: '',
                                    offset: OffsetPosition(x: 0, y: 0),
                                    luotTruyCap: 0,
                                    keyWord: [],
                                  ),
                                );
                          });
                        }),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                toggleState();
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.blue),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: Container(
                  child: Text(
                    'Bắt Đầu Quét',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      );
}

// import 'dart:math' as math;

// import 'package:flutter/material.dart';
// import 'package:flutter_compass/flutter_compass.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatefulWidget {
//   const MyApp({
//     Key? key,
//   }) : super(key: key);

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   CompassEvent? _lastRead;
//   DateTime? _lastReadAt;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           title: const Text('Flutter Compass'),
//         ),
//         body: Builder(builder: (context) {
//           return Column(
//             children: <Widget>[
//               _buildManualReader(),
//               Expanded(child: _buildCompass()),
//             ],
//           );
//         }),
//       ),
//     );
//   }

//   Widget _buildManualReader() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         children: <Widget>[
//           ElevatedButton(
//             child: Text('Read Value'),
//             onPressed: () async {
//               final CompassEvent tmp = await FlutterCompass.events!.first;
//               setState(() {
//                 _lastRead = tmp;
//                 _lastReadAt = DateTime.now();
//               });
//             },
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Text(
//                     '$_lastRead',
//                     style: Theme.of(context).textTheme.caption,
//                   ),
//                   Text(
//                     '$_lastReadAt',
//                     style: Theme.of(context).textTheme.caption,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompass() {
//     return StreamBuilder<CompassEvent>(
//       stream: FlutterCompass.events,
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Text('Error reading heading: ${snapshot.error}');
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         }

//         double? direction = snapshot.data!.heading;

//         // if direction is null, then device does not support this sensor
//         // show error message
//         if (direction == null)
//           return Center(
//             child: Text("Device does not have sensors !"),
//           );

//         return Material(
//           shape: CircleBorder(),
//           clipBehavior: Clip.antiAlias,
//           elevation: 4.0,
//           child: Container(
//             padding: EdgeInsets.all(16.0),
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//             ),
//             child: Transform.rotate(
//               angle: (direction * (math.pi / 180) * -1),
//               child: Image.asset('assets/compass.jpg'),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }


// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:ble_ips_example4/controller/requirement_state_controller.dart';
// // import 'package:ble_ips_example4/view/home_page.dart';
// // import 'package:get/get.dart';

// // void main() {
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     Get.put(RequirementStateController());

// //     final themeData = Theme.of(context);
// //     final primary = Colors.blue;

// //     return GetMaterialApp(
// //       theme: ThemeData(
// //         brightness: Brightness.light,
// //         primarySwatch: primary,
// //         appBarTheme: themeData.appBarTheme.copyWith(
// //           brightness: Brightness.light,
// //           elevation: 0.5,
// //           color: Colors.white,
// //           actionsIconTheme: themeData.primaryIconTheme.copyWith(
// //             color: primary,
// //           ),
// //           iconTheme: themeData.primaryIconTheme.copyWith(
// //             color: primary,
// //           ),
// //           textTheme: themeData.primaryTextTheme.copyWith(
// //             headline6: themeData.textTheme.headline6?.copyWith(
// //               color: primary,
// //             ),
// //           ),
// //         ),
// //       ),
// //       darkTheme: ThemeData(
// //         brightness: Brightness.dark,
// //         primarySwatch: primary,
// //       ),
// //       home: HomePage(),
// //     );
// //   }
// // }
