package com.example.battery_project1
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
{
  private val CHANNEL = "batteryStatsReader"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
      call, result ->
      // This method is invoked on the main thread.
      result.notImplemented() //TODO
    }
  }
}