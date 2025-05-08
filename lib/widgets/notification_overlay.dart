import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';

class NotificationOverlay extends StatelessWidget {
  const NotificationOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, _) {
        final notifications = notificationService.notifications;
        
        return Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          right: 16,
          child: Column(
            children: notifications.map((notification) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _NotificationCard(notification: notification),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final InAppNotification notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ListTile(
        title: Text(
          notification.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(notification.body),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.read<NotificationService>().removeNotification(notification.id);
          },
        ),
      ),
    );
  }
}
