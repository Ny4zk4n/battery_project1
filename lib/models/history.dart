// One charging session for the History tab.
class ChargeSession {
  final String deviceName;
  final String when;
  final String range;
  final String duration;

  const ChargeSession(this.deviceName, this.when, this.range, this.duration);
}

// One alert for the History tab.
class AlertEvent {
  final String text;
  final String when;

  const AlertEvent(this.text, this.when);
}
