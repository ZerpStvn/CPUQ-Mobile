import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Use your custom launcher icon
  static const String _notificationIcon = '@mipmap/launcher_icon';

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Android settings - use your custom icon
    const androidSettings = AndroidInitializationSettings(_notificationIcon);

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can navigate to queue display page
    debugPrint('Notification tapped: ${response.payload}');
  }

  // Notification channel for queue updates
  static const _queueChannelId = 'queue_notifications';
  static const _queueChannelName = 'Queue Updates';
  static const _queueChannelDescription = 'Notifications for queue status updates';

  // Show notification when user is next in line
  Future<void> showNextInLineNotification({
    required String ticketNumber,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _queueChannelId,
      _queueChannelName,
      channelDescription: _queueChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: _notificationIcon,
      color: Color(0xFF03236D),
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1, // Notification ID
      'You\'re Next!',
      'Ticket $ticketNumber - Get ready, you\'re next in line!',
      details,
      payload: 'next_in_line:$ticketNumber',
    );
  }

  // Show notification when user is now being served
  Future<void> showNowServingNotification({
    required String ticketNumber,
    required String windowName,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _queueChannelId,
      _queueChannelName,
      channelDescription: _queueChannelDescription,
      importance: Importance.max,
      priority: Priority.max,
      icon: _notificationIcon,
      color: Color(0xFFFFB800),
      enableVibration: true,
      playSound: true,
      fullScreenIntent: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      2, // Notification ID
      'Now Serving!',
      'Ticket $ticketNumber - Please proceed to $windowName',
      details,
      payload: 'now_serving:$ticketNumber',
    );
  }

  // Show notification when position changes
  Future<void> showPositionUpdateNotification({
    required String ticketNumber,
    required int position,
  }) async {
    if (position > 3) return; // Only notify for top 3 positions

    const androidDetails = AndroidNotificationDetails(
      _queueChannelId,
      _queueChannelName,
      channelDescription: _queueChannelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: _notificationIcon,
      color: Color(0xFF03236D),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    String message;
    if (position == 1) {
      message = 'You\'re next in line! Get ready.';
    } else if (position == 2) {
      message = 'Almost there! 2 more before you.';
    } else {
      message = 'Getting closer! $position more before you.';
    }

    await _notifications.show(
      3, // Notification ID for position updates
      'Queue Update',
      'Ticket $ticketNumber - $message',
      details,
      payload: 'position_update:$ticketNumber',
    );
  }

  // Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // Cancel specific notification
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}
