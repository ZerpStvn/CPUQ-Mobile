import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  static const String _notificationIcon = '@mipmap/launcher_icon';

  // Using a completely different channel key to ensure a fresh start on the device
  static const String _channelId = 'cpu_queue_urgent_v50';
  static const String _channelName = 'Queue Alerts';
  static const String _channelDesc = 'Urgent notifications for queue updates';

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings(_notificationIcon);
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidPlugin?.requestNotificationsPermission();

      // Create high importance channel with all features enabled
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          showBadge: true,
        ),
      );
    } else if (Platform.isIOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
        critical: true,
      );
    }

    _isInitialized = true;
  }

  Future<void> showNextInLineNotification({
    required String ticketNumber,
  }) async {
    // Alert when user is next in line (strong but not as intense as "now serving")
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.max,
      icon: _notificationIcon,
      color: Color(0xFF03236D),
      enableVibration: true,
      playSound: true,
      visibility: NotificationVisibility.public,
      // Stronger vibration for next in line
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      enableLights: true,
      ledColor: Color(0xFF03236D),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    await _notifications.show(
      1,
      '⚠️ You\'re Next!',
      'Ticket $ticketNumber - Get ready, you\'re next in line!',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'next_in_line:$ticketNumber',
    );
  }

  Future<void> showNowServingNotification({
    required String ticketNumber,
    required String windowName,
  }) async {
    // Enhanced Android notification with alarm-like features
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.max,
      icon: _notificationIcon,
      color: Color(0xFFFFB800),
      enableVibration: true,
      playSound: true,
      visibility: NotificationVisibility.public,
      // Alarm features - keeps ringing until dismissed
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      ongoing: true, // Makes it harder to dismiss accidentally
      autoCancel: false, // User must manually dismiss
      // Vibration pattern: wait 0ms, vibrate 1000ms, wait 500ms, vibrate 1000ms
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      enableLights: true,
      ledColor: Color(0xFFFFB800),
      ledOnMs: 1000,
      ledOffMs: 500,
      // Make it insistent (keeps playing sound/vibration)
      additionalFlags: Int32List.fromList([4]), // FLAG_INSISTENT = 4
    );

    // Enhanced iOS notification with critical alert
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // Critical alerts bypass Do Not Disturb and silent mode
      interruptionLevel: InterruptionLevel.critical,
      sound: 'default',
    );

    await _notifications.show(
      2,
      '🔔 NOW SERVING!',
      'Ticket $ticketNumber - Please proceed to $windowName NOW!',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'now_serving:$ticketNumber',
    );
  }

  Future<void> showPositionUpdateNotification({
    required String ticketNumber,
    required int position,
  }) async {
    if (position > 3) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.max,
      icon: _notificationIcon,
      color: Color(0xFF03236D),
      enableVibration: true,
      playSound: true,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    String message = position == 1
        ? 'You\'re next in line! Get ready.'
        : 'Please Proceed Near the Counter';

    await _notifications.show(
      3,
      'Queue Update',
      'Ticket $ticketNumber - $message',
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'position_update:$ticketNumber',
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // Cancel specific notification by ID
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Dismiss the ongoing "Now Serving" alarm notification
  Future<void> dismissNowServingAlarm() async {
    await _notifications.cancel(2); // ID 2 is for "Now Serving"
  }
}
