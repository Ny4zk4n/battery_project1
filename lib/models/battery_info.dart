class BatteryInfo {
  final int? level;
  final double? temperature;
  final double? voltage;
  final int? status;

  const BatteryInfo({
    this.level,
    this.temperature,
    this.voltage,
    this.status,
  });

  factory BatteryInfo.fromMap(Map<String, dynamic> map) {
    final rawLevel = map['level'] as int?;
    final rawTemp = map['temp'] as int?;
    final rawVoltage = map['voltage'] as int?;
    final rawStatus = map['status'] as int?;

    return BatteryInfo(
      level: (rawLevel == null || rawLevel == -1) ? null : rawLevel,
      temperature: (rawTemp == null || rawTemp == -1) ? null : rawTemp / 10.0,
      voltage: (rawVoltage == null || rawVoltage == -1) ? null : rawVoltage / 1000.0,
      status: (rawStatus == null || rawStatus == -1) ? null : rawStatus,
    );
  } 
  String get statusText {
  return switch (status) {
  1 => 'Unknown',
  2 => 'Charging',
  3 => 'Discharging',
  4 => 'Plugged in (not charging)',
  5 => 'Full',
  _ => 'Unknown',
};
}  
}