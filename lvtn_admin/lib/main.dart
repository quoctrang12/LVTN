import 'package:lvtn_admin/Models/Manager/PositionManager.dart';
import 'package:lvtn_admin/Models/Manager/RoomManager.dart';
import 'package:lvtn_admin/home_screen.dart';
import 'package:lvtn_admin/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

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
        home: const BLEProjectPage(
          title: 'BLE Indoor Position',
        ),
      ),
    );
  }
}
