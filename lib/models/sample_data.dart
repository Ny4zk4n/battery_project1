import 'package:flutter/material.dart';

import 'device.dart';
import 'history.dart';

const Device kPhone = Device(
  name: 'This phone',
  icon: Icons.smartphone,
  designCapacity: 4500,
  chargePercent: 78,
  charging: true,
  statusText: 'Charging, full in 41 min',
  power: '+7.8 W',
  temperature: '31 °C',
  current: '+1850 mA',
  voltage: '4.21 V',
  cycles: '187',
  // 60% falling to 22%, then charging up to 78%
  chargeHistory: [60, 56, 52, 47, 43, 38, 33, 28, 24, 22, 36, 50, 64, 72, 78],
  healthHistory: [97, 97, 96, 96, 95, 95, 94, 93, 93, 92, 92, 91],
  // The average of these is 4,095 mAh = 91% of 4,500 mAh
  records: [
    ChargeRecord('13 Nov', 4100),
    ChargeRecord('12 Nov', 4088),
    ChargeRecord('10 Nov', 4092),
    ChargeRecord('9 Nov', 4100),
    ChargeRecord('7 Nov', 4085),
    ChargeRecord('6 Nov', 4098),
    ChargeRecord('4 Nov', 4120),
    ChargeRecord('3 Nov', 4075),
    ChargeRecord('1 Nov', 4090),
    ChargeRecord('31 Oct', 4102),
    ChargeRecord('29 Oct', 4080),
    ChargeRecord('28 Oct', 4110),
  ],
  apps: [
    AppUsage('YouTube', '2 h 10 min on screen', 2.4),
    AppUsage('Instagram', '48 min on screen', 1.9),
    AppUsage('Chrome', '1 h 35 min on screen', 1.6),
  ],
);

const Device kTablet = Device(
  name: 'Galaxy Tab S8',
  icon: Icons.tablet_android,
  designCapacity: 8000,
  chargePercent: 64,
  charging: false,
  statusText: 'Using 3.1 W, about 10 h left',
  power: '-3.1 W',
  temperature: '27 °C',
  current: '-805 mA',
  voltage: '3.85 V',
  cycles: '96',
  chargeHistory: [92, 92, 91, 88, 84, 84, 83, 80, 76, 73, 73, 70, 68, 66, 64],
  healthHistory: [93, 93, 92, 92, 91, 91, 90, 90, 89, 89, 88, 88],
  // The average of these is 7,040 mAh = 88% of 8,000 mAh
  records: [
    ChargeRecord('12 Nov', 7060),
    ChargeRecord('9 Nov', 7025),
    ChargeRecord('6 Nov', 7050),
    ChargeRecord('3 Nov', 7030),
    ChargeRecord('31 Oct', 7045),
    ChargeRecord('28 Oct', 7020),
    ChargeRecord('25 Oct', 7055),
    ChargeRecord('22 Oct', 7035),
  ],
  apps: [
    AppUsage('Netflix', '1 h 50 min on screen', 3.6),
    AppUsage('Chrome', '55 min on screen', 2.8),
    AppUsage('Kindle', '40 min on screen', 1.9),
  ],
);

const List<ChargeSession> kSessions = [
  ChargeSession('This phone', 'Today, 16:40', '22% → 78%', 'Charging now'),
  ChargeSession('This phone', '13 Nov, 23:05', '31% → 100%', '1 h 12 min'),
  ChargeSession('Galaxy Tab S8', '12 Nov, 21:30', '18% → 100%', '2 h 05 min'),
  ChargeSession('This phone', '12 Nov, 08:15', '27% → 100%', '1 h 16 min'),
  ChargeSession('This phone', '10 Nov, 19:42', '35% → 92%', '58 min'),
  ChargeSession('Galaxy Tab S8', '9 Nov, 22:10', '24% → 100%', '1 h 52 min'),
];

const List<AlertEvent> kAlerts = [
  AlertEvent('Earbuds dropped below 20%', 'Today, 17:52'),
  AlertEvent('Galaxy Tab S8 dropped below 20%', '12 Nov, 21:14'),
  AlertEvent('This phone reached 41 °C while charging', '9 Nov, 14:10'),
];
