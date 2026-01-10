import 'package:flutter/material.dart';

class Announcement {
  final String title;
  final String description;
  final IconData icon;
  final Color iconBackground;
  final DateTime date;

  Announcement({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBackground,
    required this.date,
  });
}
