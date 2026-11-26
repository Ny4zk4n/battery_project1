import 'package:flutter/services.dart';
import 'models/battery_info.dart';
class BatteryService  {
    static const MethodChannel _channel = MethodChannel('batteryStatsReader');

  Future<int?> getBatteryLevel() async {
    try {
      final int? batteryLevel = await _channel.invokeMethod<int>('getBatteryLevel');
      return batteryLevel;
    } on PlatformException catch (e) {
      // Handle platform-specific errors (e.g., e.code, e.message)
      print(e);
      return null;
    } catch (e) {
      // Handle any other unexpected errors
      print(e);
      return null;
    }
  }
  Future<BatteryInfo?> getBatteryInfo() async {
    final Map<String, dynamic>? batteryInfoMap = await _channel.invokeMapMethod<String, dynamic>('getBatteryInfo');
    if (batteryInfoMap == null) {
      return null;
    }
    return BatteryInfo.fromMap(batteryInfoMap);
}
}