import 'package:flutter/material.dart';

import 'theme.dart';

// Health rule: 85%+ green "Good", 70-84% amber "Worn", below 70% red.
Color healthColor(int percent) {
  if (percent >= 85) return kAccent;
  if (percent >= 70) return kAmber;
  return kRed;
}

String healthLabel(int percent) {
  if (percent >= 85) return 'Good';
  if (percent >= 70) return 'Worn';
  return 'Replace soon';
}

// Writes 4095 as "4,095".
String formatNumber(int value) {
  String digits = value.abs().toString();
  String result = '';
  while (digits.length > 3) {
    result = ',${digits.substring(digits.length - 3)}$result';
    digits = digits.substring(0, digits.length - 3);
  }
  result = digits + result;
  return value < 0 ? '-$result' : result;
}

// Padding around a page. On very wide screens the side padding grows,
// so the content stays centered and at most kMaxContentWidth wide.
EdgeInsets pagePadding(BuildContext context) {
  final double screenWidth = MediaQuery.sizeOf(context).width;
  double side = (screenWidth - kMaxContentWidth) / 2;
  if (side < 16) side = 16;
  return EdgeInsets.symmetric(horizontal: side, vertical: 16);
}
