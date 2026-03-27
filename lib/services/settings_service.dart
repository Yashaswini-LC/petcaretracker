import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _soundEnabled = true;
  static bool _hapticsEnabled = true;
  static const String _soundKey = 'sound_enabled';
  static const String _hapticsKey = 'haptics_enabled';

static Future<void> init() async {
  // Load prefs first (web-safe)
  final prefs = await SharedPreferences.getInstance();
  _soundEnabled = prefs.getBool(_soundKey) ?? true;
  _hapticsEnabled = prefs.getBool(_hapticsKey) ?? true;

  // Skip notifications on web
  if (kIsWeb) return;

  // Notifications setup (mobile only)
  try {
    const AndroidInitializationSettings android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings ios = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(android: android, iOS: ios);
    await _notifications.initialize(settings);
  } catch (e) {
    print("Notifications init failed (expected on web): $e");
  }
}

  static Future<void> toggleSound(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, enabled);
  }

  static Future<void> toggleHaptics(bool enabled) async {
    _hapticsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsKey, enabled);
  }

  static void hapticFeedback() {
    if (_hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  static Future<void> showPetReminder(String petName) async {
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'pet_reminder',
      'Pet Reminders',
      channelDescription: 'Daily pet care reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails ios = DarwinNotificationDetails();
    const NotificationDetails details = NotificationDetails(android: android, iOS: ios);
    await _notifications.show(0, 'Time for $petName!', "Don't forget to feed your pet! 🐶", details);
  }


  static bool get soundEnabled => _soundEnabled;
  static bool get hapticsEnabled => _hapticsEnabled;
}
