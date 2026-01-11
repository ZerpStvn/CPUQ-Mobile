import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cpuq/utils/global_theme.dart';

class PermissionService {
  static Future<void> checkAndRequestPermissions(BuildContext context) async {
    // Check notification permission (Android 13+)
    final notificationStatus = await Permission.notification.status;

    if (notificationStatus.isDenied) {
      if (context.mounted) {
        await _showPermissionDialog(context);
      }
    }
  }

  static Future<void> _showPermissionDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Permissions Required',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CPU App needs the following permissions to work properly:',
                style: TextStyle(
                  fontSize: 14,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 16),
              _buildPermissionItem(
                icon: Icons.wifi,
                title: 'Internet Access',
                description: 'To connect to queue services',
              ),
              const SizedBox(height: 12),
              _buildPermissionItem(
                icon: Icons.notifications,
                title: 'Notifications',
                description: 'To receive queue updates',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Later',
                style: TextStyle(
                  color: textGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _requestPermissions();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: neutralWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Allow',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: secondaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: textGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Future<void> _requestPermissions() async {
    // Request notification permission
    await Permission.notification.request();
  }

  // Check if all required permissions are granted
  static Future<bool> arePermissionsGranted() async {
    final notificationStatus = await Permission.notification.status;
    return notificationStatus.isGranted;
  }

  // Open app settings if permission is permanently denied
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
