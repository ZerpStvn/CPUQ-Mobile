import 'package:flutter/material.dart';

class ServiceItem {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  ServiceItem({
    required this.title,
    required this.icon,
    this.iconColor,
    this.onTap,
  });
}
