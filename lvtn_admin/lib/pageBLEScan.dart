import 'package:lvtn_admin/Models/InforPosition.dart';
import 'package:lvtn_admin/Models/Manager/PositionManager.dart';
import 'package:lvtn_admin/Models/offsetPosition.dart';
import 'package:lvtn_admin/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:rolling_switch/rolling_switch.dart';
import 'package:provider/provider.dart';

import 'ble_data.dart';

class pageBLEScan extends StatefulWidget {
  const pageBLEScan({super.key});

  @override
  State<pageBLEScan> createState() => _pageBLEScanState();
}

class _pageBLEScanState extends State<pageBLEScan> {
  var bleController = Get.put(BLEResult());

  String deviceName = '';
  String macAddress = '';
  String rssi = '';
  String serviceUUID = '';
  String manuFactureData = '';
  String tp = '';
  List<InforPosition> infor = [];
  @override
  initState() {
    infor = context.read<PositionManager>().positions.infor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        itemCount: bleController.scanResultList.length,
        itemBuilder: (context, index) =>
            widgetBLEList(index, bleController.scanResultList[index]),
      ),
    );
  }

  Widget widgetBLEList(int index, ScanResult1 r) {
    toStringBLE(r);
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
          index, 2, -temp.rssi1M, temp.offset.x, temp.offset.y, 0);
    }

    // bleController.kalmanFilter();

    serviceUUID.isEmpty ? serviceUUID = 'null' : serviceUUID;
    manuFactureData.isEmpty ? manuFactureData = 'null' : manuFactureData;
    bool switchFlag = bleController.flagList[index];
    switchFlag ? deviceName = '$deviceName (active)' : deviceName;

    bleController.updateselectedDeviceIdxList();
    // if (deviceName == 'N/A') return Container();
    return ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: Colors.cyan,
        child: Icon(
          Icons.bluetooth,
          color: Colors.white,
        ),
      ),
      title: Text(deviceName,
          style:
              TextStyle(color: switchFlag ? Colors.lightBlue : Colors.black)),
      subtitle: Text(macAddress,
          style:
              TextStyle(color: switchFlag ? Colors.lightBlue : Colors.black)),
      trailing: Text(rssi,
          style:
              TextStyle(color: switchFlag ? Colors.lightBlue : Colors.black)),
      children: <Widget>[
        ListTile(
          title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'UUID : $serviceUUID\nManufacture data : $manuFactureData\nTX power : ${tp == 'null' ? tp : '${tp} dBm'}',
                  style: const TextStyle(fontSize: 10),
                ),
                const Padding(padding: EdgeInsets.all(2)),
                Row(
                  children: [
                    const Spacer(),
                    RollingSwitch.icon(
                      initialState: bleController.flagList[index],
                      onChanged: (bool state) {
                        if (state) {
                          bleController.updateFlagList(
                              flag: state, index: index);
                          context.read<PositionManager>().addPosition(
                                InforPosition(
                                  id: index,
                                  name: r.device.name,
                                  offset: OffsetPosition(x: 0.0, y: 0.0),
                                  rssi1M: 67,
                                  macAddress: r.device.id.id,
                                ),
                              );
                        } else {
                          bleController.updateFlagList(
                              flag: state, index: index);
                          context.read<PositionManager>().deletePosition(
                                InforPosition(
                                  id: index,
                                  name: r.device.name,
                                  offset: OffsetPosition(x: 0.0, y: 0.0),
                                  rssi1M: 67,
                                  macAddress: r.device.id.id,
                                ),
                              );
                        }
                      },
                      rollingInfoRight: const RollingIconInfo(
                        icon: Icons.flag,
                        text: Text(
                          'Active',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      rollingInfoLeft: const RollingIconInfo(
                        icon: Icons.check,
                        backgroundColor: Colors.grey,
                        text: Text('Inactive'),
                      ),
                    )
                  ],
                ),
              ]),
        )
      ],
    );
  }

  /* string */
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
}
