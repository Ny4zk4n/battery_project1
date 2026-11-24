import 'package:flutter/material.dart';

import 'models/device.dart';
import 'screens/add_device_screen.dart';
import 'screens/detail_screen.dart';

// Opens the detail screen of a device.
void openDetail(BuildContext context, Device device) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => DetailScreen(device: device)),
  );
}

// Opens the Add device screen.
void openAddDevice(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AddDeviceScreen()),
  );
}
