package com.example.battery_project1

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val CHANNEL = "batteryStatsReader"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      if ("getBatteryLevel" == call.method) {
        val level = getBatteryLevel()
        result.success(level)
      } else if ("getBatteryInfo" == call.method) {
        val info = getBatteryInfo()
        result.success(info)
      } else {
        result.notImplemented()
      }
    }
  }

  private fun getBatteryLevel(): Int {
    val batteryStatus: Intent? = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
    val level = batteryStatus?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
    val scale = batteryStatus?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1

    if (level == -1 || scale == -1) {
      return -1
    }
    return (level * 100) / scale
  }

  private fun getBatteryInfo(): Map<String, Int> {
    val batteryStatus: Intent? = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
    val percentage = getBatteryLevel()
    val batteryTemp = batteryStatus?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1) ?: -1
    val batteryVol = batteryStatus?.getIntExtra(BatteryManager.EXTRA_VOLTAGE, -1) ?: -1
    val batteryStat = batteryStatus?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1

    return mapOf(
      "level" to percentage,
      "temp" to batteryTemp,
      "voltage" to batteryVol,
      "status" to batteryStat
    )
  }
}