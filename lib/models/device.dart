import 'package:flutter/material.dart';

import '../utils.dart';

// One finished charge: the date and the capacity that was measured.
class ChargeRecord {
  final String date;
  final int capacity; // in mAh

  const ChargeRecord(this.date, this.capacity);
}

// How much power one app used.
class AppUsage {
  final String name;
  final String screenTime;
  final double watts;

  const AppUsage(this.name, this.screenTime, this.watts);
}

// Everything the app knows about one device.
// Health is not stored: it is calculated from the charge records.
class Device {
  final String name;
  final IconData icon;
  final int designCapacity; // mAh when the battery was new
  final int chargePercent;
  final bool charging;
  final String statusText;
  final String power;
  final String temperature;
  final String current;
  final String voltage;
  final String cycles;
  final List<double> chargeHistory; // charge % over the last 24 hours
  final List<double> healthHistory; // health % over the last 12 months
  final List<ChargeRecord> records; // last charges, newest first
  final List<AppUsage> apps;

  const Device({
    required this.name,
    required this.icon,
    required this.designCapacity,
    required this.chargePercent,
    required this.charging,
    required this.statusText,
    required this.power,
    required this.temperature,
    required this.current,
    required this.voltage,
    required this.cycles,
    required this.chargeHistory,
    required this.healthHistory,
    required this.records,
    required this.apps,
  });

  // Average measured capacity of all charge records, in mAh.
  int get averageCapacity {
    if (records.isEmpty) return 0;
    int sum = 0;
    for (final ChargeRecord record in records) {
      sum += record.capacity;
    }
    return (sum / records.length).round();
  }

  // Health = average measured capacity compared with the capacity when new.
  double get healthExact => averageCapacity / designCapacity * 100;
  int get health => healthExact.round();

  String get capacityText =>
      '${formatNumber(averageCapacity)} of ${formatNumber(designCapacity)} mAh';
  String get estimateText => 'Estimated from ${records.length} charges';

  // Values taken from the 12 month health history.
  int get healthYearAgo => healthHistory.first.round();
  int get healthHalfYearAgo =>
      healthHistory[(healthHistory.length - 1) ~/ 2].round();
  int get healthDrop => (healthHistory.first - healthHistory.last).round();

  // Lowest charge level in the last 24 hours.
  double get lowestCharge {
    double lowest = chargeHistory.first;
    for (final double value in chargeHistory) {
      if (value < lowest) lowest = value;
    }
    return lowest;
  }
}
