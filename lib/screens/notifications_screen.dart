import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/sierro_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  static const routeName = '/notifications';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppStateScope.of(context).markNotificationsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final notifications = state.notifications;
    return SierroPage(
      child: Column(
        children: [
          const SierroHeader(
            title: 'Notifications',
            leading: BackCircleButton(),
            centerTitle: true,
          ),
          Expanded(
            child: notifications.isEmpty
                ? const EmptyState(
                    title: 'No notifications yet',
                    message:
                        'You will see battery alerts, power outage notifications, and device updates here.',
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Dismissible(
                        key: ValueKey(notification.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 22),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) =>
                            state.deleteNotification(notification.id),
                        child: _NotificationCard(notification: notification),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return SierroCard(
      margin: const EdgeInsets.only(bottom: 12),
      color: notification.read ? AppColors.surface : const Color(0xFF351712),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 7),
            decoration: BoxDecoration(
              color: notification.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  notification.message,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.time,
                  style: const TextStyle(
                    color: AppColors.textDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_left_rounded, color: AppColors.textDim),
        ],
      ),
    );
  }
}
