import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:io';

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
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      await androidPlugin?.requestNotificationsPermission();

      // Create high importance channel with all features enabled
      await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        showBadge: true,
      ));
    }

    _isInitialized = true;
  }

  Future<void> showNextInLineNotification({
    required String ticketNumber,
  }) async {
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
      interruptionLevel: InterruptionLevel.active,
    );

    await _notifications.show(
      1,
      'You\'re in queue',
      'Ticket $ticketNumber - Please wait',
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'next_in_line:$ticketNumber',
    );
  }

  Future<void> showNowServingNotification({
    required String ticketNumber,
    required String windowName,
  }) async {
    const androidDetails = AndroidNotificationDetails(
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
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    await _notifications.show(
      2,
      'Now Serving!',
      'Ticket $ticketNumber - Please proceed to $windowName',
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
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
        : 'Getting closer! $position more before you.';

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
}
