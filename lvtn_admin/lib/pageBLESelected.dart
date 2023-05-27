import 'dart:math';

import 'package:lvtn_admin/Models/InforPosition.dart';
import 'package:lvtn_admin/Models/Manager/PositionManager.dart';
import 'package:lvtn_admin/Models/offsetPosition.dart';
import 'package:lvtn_admin/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'ble_data.dart';

class pageBLESelected extends StatefulWidget {
  const pageBLESelected({super.key});

  @override
  State<pageBLESelected> createState() => _pageBLESelectedState();
}

class _pageBLESelectedState extends State<pageBLESelected> {
  var bleController = Get.put(BLEResult());

  // BLE value
  String deviceName = '';
  String macAddress = '';
  String rssi = '';
  String serviceUUID = '';
  String manuFactureData = '';
  String tp = '';

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          /* listview */
          ListView.separated(
              itemCount: bleController.selectedDeviceIdxList.length,
              itemBuilder: (context, index) => widgetSelectedBLEList(
                    index,
                    bleController.scanResultList[
                        bleController.selectedDeviceIdxList[index]],
                  ),
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider()),
    );
  }

  /* log distance path loss model */
  num logDistancePathLoss(String rssi, double alpha, double constantN) =>
      pow(10.0, ((alpha - double.parse(rssi)) / (10 * constantN)));

  /* string */
  void toStringBLE(ScanResult1 r) {
    deviceName = deviceNameCheck(r);
    macAddress = r.device.id.id;
    rssi = bleController.averageRSSI(r.rssi).toString();

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

  Widget widgetSelectedBLEList(int currentIdx, ScanResult1 r) {
    toStringBLE(r);

    bleController.updateBLEList(
        deviceName: deviceName,
        macAddress: macAddress,
        rssi: rssi,
        serviceUUID: serviceUUID,
        manuFactureData: manuFactureData,
        tp: tp);
    double constantN = bleController.selectedConstNList[currentIdx].toDouble();
    double alpha = bleController.selectedRSSI_1mList[currentIdx].toDouble();
    num distance = logDistancePathLoss(rssi, alpha, constantN);
    bleController.selectedDistanceList[currentIdx] = distance;
    String constN = bleController.selectedConstNList[currentIdx].toString();
    String rssi1m = bleController.selectedRSSI_1mList[currentIdx].toString();
    return ExpansionTile(
      //leading: leading(r),
      title: Text('$deviceName ($macAddress)',
          style: const TextStyle(color: Colors.black)),
      subtitle: Text(
          '\n Alias : Anchor$currentIdx\n N : $constN\n RSSI at 1m : ${rssi1m}dBm',
          style: const TextStyle(color: Colors.blueAccent)),
      trailing: Text('${distance.toStringAsPrecision(3)}m',
          style: const TextStyle(color: Colors.black)),
      children: <Widget>[
        ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: SpinBox(
                    min: 2.0,
                    max: 4.0,
                    value:
                        bleController.selectedConstNList[currentIdx].toDouble(),
                    decimals: 1,
                    step: 0.1,
                    onChanged: (value) =>
                        bleController.selectedConstNList[currentIdx] = value,
                    decoration: const InputDecoration(
                        labelText:
                            'N (Constant depends on the Environmental factor)'),
                  )),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SpinBox(
                  min: -100,
                  max: -30,
                  value:
                      bleController.selectedRSSI_1mList[currentIdx].toDouble(),
                  decimals: 0,
                  step: 1,
                  onChanged: (value) => bleController
                      .selectedRSSI_1mList[currentIdx] = value.toInt(),
                  decoration: const InputDecoration(labelText: 'RSSI at 1m'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SpinBox(
                  min: 0.0,
                  max: 20.0,
                  value:
                      bleController.selectedCenterXList[currentIdx].toDouble(),
                  decimals: 1,
                  step: 0.1,
                  onChanged: (value) =>
                      bleController.selectedCenterXList[currentIdx] = value,
                  decoration: const InputDecoration(labelText: 'Center X [m]'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SpinBox(
                  min: 0.0,
                  max: 20.0,
                  value:
                      bleController.selectedCenterYList[currentIdx].toDouble(),
                  decimals: 1,
                  step: 0.1,
                  onChanged: (value) =>
                      bleController.selectedCenterYList[currentIdx] = value,
                  decoration: const InputDecoration(labelText: 'Center Y [m]'),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: context
                                  .read<PositionManager>()
                                  .positions
                                  .infor
                                  .firstWhereOrNull((element) =>
                                      element.macAddress == macAddress) !=
                              null
                          ? TextButton(
                              onPressed: () {
                                context
                                    .read<PositionManager>()
                                    .updatePosition(InforPosition(
                                      id: currentIdx,
                                      name: bleController
                                          .deviceNameList[currentIdx],
                                      offset: OffsetPosition(
                                        x: bleController
                                            .selectedCenterXList[currentIdx],
                                        y: bleController
                                            .selectedCenterYList[currentIdx],
                                      ),
                                      rssi1M: -bleController
                                          .selectedRSSI_1mList[currentIdx],
                                      macAddress: r.device.id.id,
                                    ))
                                    .then(
                                      (value) => showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text(
                                              "Cập nhật thành công!!"),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text("OK"),
                                              onPressed: () {
                                                Navigator.of(ctx).pop(true);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                              },
                              child: Text(
                                'Cập nhật',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 19),
                              ),
                            )
                          : TextButton(
                              onPressed: () {
                                context
                                    .read<PositionManager>()
                                    .addPosition(InforPosition(
                                      id: currentIdx,
                                      name: bleController
                                          .deviceNameList[currentIdx],
                                      offset: OffsetPosition(
                                        x: bleController
                                            .selectedCenterXList[currentIdx],
                                        y: bleController
                                            .selectedCenterYList[currentIdx],
                                      ),
                                      rssi1M: -bleController
                                          .selectedRSSI_1mList[currentIdx],
                                      macAddress: r.device.id.id,
                                    ))
                                    .then(
                                      (value) => showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text(
                                              "Thêm Anchor thành công!!"),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text("OK"),
                                              onPressed: () {
                                                Navigator.of(ctx).pop(true);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                              },
                              child: Text(
                                'Thêm',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 19),
                              ),
                            ),
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
