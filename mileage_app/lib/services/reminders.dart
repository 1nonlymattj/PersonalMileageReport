// lib/services/reminders.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import '../utils/cache_keys.dart';

const String kDraftReminderTaskUniqueName = 'draftReminderTask';
const String kDraftReminderWorkerName = 'draftReminderCheck';

const int _twelveHoursMs = 12 * 60 * 60 * 1000;

final FlutterLocalNotificationsPlugin _notifs =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const init = InitializationSettings(android: android);

  await _notifs.initialize(init);

  // Android 13+ permission prompt (safe to call on older versions)
  await _notifs
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  const channel = AndroidNotificationChannel(
    'draft_reminders',
    'Draft Reminders',
    description: 'Reminds you to submit saved mileage/maintenance drafts.',
    importance: Importance.high,
  );

  await _notifs
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> showReminder(String title, String body) async {
  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'draft_reminders',
      'Draft Reminders',
      channelDescription:
          'Reminds you to submit saved mileage/maintenance drafts.',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  // Unique-ish id; fine for simple reminders
  final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  await _notifs.show(id, title, body, details);
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final sp = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;

    bool mileageDraftExists() {
      final s = sp.getString(CacheKeys.mileageStart) ?? '';
      final e = sp.getString(CacheKeys.mileageEnd) ?? '';
      final a = sp.getString(CacheKeys.mileageAmount) ?? '';
      return s.isNotEmpty || e.isNotEmpty || a.isNotEmpty;
    }

    bool maintDraftExists() {
      final t = sp.getString(CacheKeys.maintType) ?? '';
      final c = sp.getString(CacheKeys.maintCost) ?? '';
      return t.isNotEmpty || c.isNotEmpty;
    }

    Future<void> maybeRemindMileage() async {
      final touched = sp.getInt(CacheKeys.mileageDraftTouchedAt);
      if (!mileageDraftExists() || touched == null) return;

      // Only after 12 hours since last edit
      if (now - touched < _twelveHoursMs) return;

      // Prevent spam: remind at most once per 12 hours
      final lastReminded = sp.getInt(CacheKeys.mileageDraftLastRemindedAt) ?? 0;
      if (now - lastReminded < _twelveHoursMs) return;

      await initNotifications();
      await showReminder(
        'Submit Mileage?',
        'You have mileage entered but not submitted.',
      );

      await sp.setInt(CacheKeys.mileageDraftLastRemindedAt, now);
    }

    Future<void> maybeRemindMaint() async {
      final touched = sp.getInt(CacheKeys.maintDraftTouchedAt);
      if (!maintDraftExists() || touched == null) return;

      if (now - touched < _twelveHoursMs) return;

      final lastReminded = sp.getInt(CacheKeys.maintDraftLastRemindedAt) ?? 0;
      if (now - lastReminded < _twelveHoursMs) return;

      await initNotifications();
      await showReminder(
        'Submit Maintenance?',
        'You have maintenance entered but not submitted.',
      );

      await sp.setInt(CacheKeys.maintDraftLastRemindedAt, now);
    }

    await maybeRemindMileage();
    await maybeRemindMaint();

    return Future.value(true);
  });
}

Future<void> initWorkmanager() async {
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  // Android minimum periodic interval is 15 minutes
  await Workmanager().registerPeriodicTask(
    kDraftReminderTaskUniqueName,
    kDraftReminderWorkerName,
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingWorkPolicy.keep, // don't duplicate tasks
  );
}
