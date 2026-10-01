import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/mock_data.dart';
import '../../models/notification.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(18),
          itemCount: MockData.notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = MockData.notifications[index];
            return _NotificationTile(item: item);
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final AppNotificationItem item;

  @override
  Widget build(BuildContext context) {
    final color = switch (item.type) {
      AppNotificationType.information => AppTheme.primary,
      AppNotificationType.warning => AppTheme.amber,
      AppNotificationType.urgent => AppTheme.red,
      AppNotificationType.success => AppTheme.green,
    };
    final background = color.withValues(alpha: 0.08);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            switch (item.type) {
              AppNotificationType.information => Icons.info_rounded,
              AppNotificationType.warning => Icons.warning_amber_rounded,
              AppNotificationType.urgent => Icons.error_rounded,
              AppNotificationType.success => Icons.check_circle_rounded,
            },
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy),
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: const TextStyle(color: AppTheme.charcoal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
