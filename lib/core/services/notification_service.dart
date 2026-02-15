import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

// Callback for Android Alarm Manager - must be top-level function
@pragma('vm:entry-point')
void importReminderAlarmCallback() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    
    final prefs = await SharedPreferences.getInstance();
    final lastImportStr = prefs.getString('last_import_date');
    final lastReminderFor = prefs.getString(NotificationService.lastReminderKeyPublic);
    
    if (lastImportStr == null) {
      return;
    }
    
    final lastImport = DateTime.parse(lastImportStr);
    final elapsed = DateTime.now().difference(lastImport);
    
    if (elapsed >= NotificationService.importReminderDelayPublic) {
      // Check if already reminded
      if (lastReminderFor == lastImportStr) {
        return;
      }
      
      // Show notification
      final plugin = FlutterLocalNotificationsPlugin();
      
      const androidInit = AndroidInitializationSettings('@drawable/ic_notification');
      await plugin.initialize(const InitializationSettings(android: androidInit));
      
      const androidDetails = AndroidNotificationDetails(
        'import_reminder',
        'Import reminders',
        channelDescription: 'Reminders to import workouts',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );
      
      final title = prefs.getString('reminder_title') ?? 'Reminder';
      final body = prefs.getString('reminder_body') ?? 'Time to check your workouts';
      
      await plugin.show(
        1001,
        title,
        body,
        const NotificationDetails(android: androidDetails),
      );
      
      await prefs.setString(NotificationService.lastReminderKeyPublic, lastImportStr);
    }
  } catch (e) {
    // Silent failure - alarm manager callback
  }
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const int _importReminderId = 1001;
  static const String _channelId = 'import_reminder';
  static const String _channelName = 'Import reminders';
  static const String _channelDescription = 'Reminders to import workouts';
  static const String _lastReminderKey = 'last_import_reminder_for';
  static const Duration _importReminderDelay = Duration(days: 3);
  static const int _alarmId = 1001;
  static bool _alarmManagerInitialized = false;
  
  // Public accessors for callback
  static const String lastReminderKeyPublic = _lastReminderKey;
  static const Duration importReminderDelayPublic = _importReminderDelay;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _permissionRequested = false;
  Timer? _androidTimer;

  bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> init() async {
    if (kIsWeb || _initialized) return;

    if (_isAndroid && !_alarmManagerInitialized) {
      await AndroidAlarmManager.initialize();
      _alarmManagerInitialized = true;
    }

    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@drawable/ic_notification');
    const initSettings = InitializationSettings(
      android: androidInit,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (!_isAndroid || _permissionRequested) {
      return;
    }

    _permissionRequested = true;

    try {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    } catch (e) {
      // Permission request failed - continue anyway
    }
  }

  NotificationDetails _buildDetails() {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    return const NotificationDetails(
      android: androidDetails,
    );
  }

  Future<void> scheduleImportReminder({
    required DateTime lastImportDate,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;

    await init();

    await _plugin.cancel(_importReminderId);

    final scheduledAt = lastImportDate.add(_importReminderDelay);
    final now = DateTime.now();

    // Save last import date and notification text for alarm callback
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_import_date', lastImportDate.toIso8601String());
    await prefs.setString('reminder_title', title);
    await prefs.setString('reminder_body', body);

    if (scheduledAt.isBefore(now)) {
      // Don't show immediately on fresh import, wait for the delay
      return;
    }

    // Schedule in-app timer for when app is open
    _scheduleAndroidTimer(lastImportDate, title, body);

    // Schedule Alarm Manager for background
    await AndroidAlarmManager.oneShotAt(
      scheduledAt,
      _alarmId,
      importReminderAlarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: false,
    );
  }

  Future<void> cancelImportReminder() async {
    if (kIsWeb) return;

    await init();

    if (_isAndroid) {
      _androidTimer?.cancel();
      _androidTimer = null;
      await AndroidAlarmManager.cancel(_alarmId);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastReminderKey);
      return;
    }

    await _plugin.cancel(_importReminderId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastReminderKey);
  }

  void _scheduleAndroidTimer(
    DateTime lastImportDate,
    String title,
    String body,
  ) {
    _androidTimer?.cancel();
    _androidTimer = null;

    final scheduledAt = lastImportDate.add(_importReminderDelay);
    final now = DateTime.now();

    if (scheduledAt.isBefore(now)) {
      // Already passed, will be shown when app opens
      return;
    }

    final delay = scheduledAt.difference(now);
    _androidTimer = Timer(delay, () {
      _showIfNotAlreadyReminded(lastImportDate, title, body);
    });
  }

  Future<void> _showIfNotAlreadyReminded(
    DateTime lastImportDate,
    String title,
    String body,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final lastReminderFor = prefs.getString(_lastReminderKey);
    final lastImportIso = lastImportDate.toIso8601String();

    if (lastReminderFor == lastImportIso) {
      return;
    }

    await _plugin.show(
      _importReminderId,
      title,
      body,
      _buildDetails(),
    );

    await prefs.setString(_lastReminderKey, lastImportIso);
  }
}
