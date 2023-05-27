import 'package:lvtn_admin/ble_data.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/* device name check */
String deviceNameCheck(ScanResult1 r) {
  String name;

  if (r.device.name.isNotEmpty) {
    // Is device.name
    name = r.device.name;
  } else if (r.advertisementData.localName.isNotEmpty) {
    // Is advertisementData.localName
    name = r.advertisementData.localName;
  } else {
    // null
    name = 'N/A';
  }
  return name;
}
