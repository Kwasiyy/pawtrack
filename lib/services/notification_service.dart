import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final List<InAppNotification> _notifications = [];
  
  List<InAppNotification> get notifications => List.unmodifiable(_notifications);
  
  NotificationService._internal() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        debugPrint('Notification tapped: ${response.payload}');
      },
    );
  }

  Future<void> scheduleReminder({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch % 100000;
    final now = DateTime.now();
    
    // If the scheduled date is today, show notification immediately
    if (scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day) {
      await _localNotifications.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders_channel',
            'Reminders',
            channelDescription: 'Channel for scheduled reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
    } else {
      // Schedule for future date
      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders_channel',
            'Reminders',
            channelDescription: 'Channel for scheduled reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    }

    // Also show in-app notification
    showNotification(
      title: title,
      body: body,
      duration: const Duration(seconds: 3),
    );
  }

  void showNotification({
    required String title,
    required String body,
    Duration duration = const Duration(seconds: 3),
  }) {
    final notification = InAppNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      timestamp: DateTime.now(),
    );
    
    _notifications.insert(0, notification);
    notifyListeners();

    // Auto-remove notification after duration
    Timer(duration, () {
      removeNotification(notification.id);
    });
  }

  void removeNotification(int id) {
    _notifications.removeWhere((notification) => notification.id == id);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  Future<void> cancelReminder(int id) async {
    await _localNotifications.cancel(id);
  }

  Future<void> cancelAllReminders() async {
    await _localNotifications.cancelAll();
  }
}

class InAppNotification {
  final int id;
  final String title;
  final String body;
  final DateTime timestamp;

  InAppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
  });
}
