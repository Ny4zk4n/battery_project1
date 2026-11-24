import 'package:flutter/material.dart';

// Colors
const Color kBg = Color(0xFF0F1418);
const Color kCard = Color(0xFF182028);
const Color kBorder = Color(0xFF2A3640);
const Color kText = Color(0xFFE8EEF2);
const Color kMuted = Color(0xFF9FB0BD);
const Color kAccent = Color(0xFF4ADE80);
const Color kAmber = Color(0xFFFBBF24);
const Color kRed = Color(0xFFF87171);

// Screen width where the layout switches from phone to tablet.
const double kTabletWidth = 600;
// The content never gets wider than this, even on a big monitor.
const double kMaxContentWidth = 1100;
// The app is never laid out narrower than this. Real phones are at least
// 320 px wide. In a narrower window the app scrolls sideways instead.
const double kMinAppWidth = 320;

// A thin line between rows inside a card.
const Widget kDivider = Divider(height: 1, color: kBorder);
