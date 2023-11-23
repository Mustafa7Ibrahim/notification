
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// The [NotificationAppLaunchDetails] class contains
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialized in the `main` function
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

/// Streams are created so that app can respond to notification-related events
final StreamController<String?> selectNotificationStream = StreamController<String?>.broadcast();

/// The [NotificationAppLaunchDetails] class contains
const MethodChannel platform = MethodChannel(
  'dexterx.dev/flutter_local_notifications_example',
);

/// The [NotificationAppLaunchDetails] class contains
String? selectedNotificationPayload;

/// A notification action which triggers a url launch event
// TODO: add your url launch action id e.g. 'id_1'
const String urlLaunchActionId = '';

// TODO: add your navigation action id e.g. 'id_2'
/// A notification action which triggers a App navigation event
const String navigationActionId = '';

// TODO: add your notification channel name id e.g. 'notification_channel_id'
/// A notification action which triggers a App navigation event
const notificationChannelId = '';

// TODO: add your notification channel name id e.g. 'notification_channel_name'
/// A notification action which triggers a App navigation event
const notificationChannelName = '';

// TODO: add your notification channel description id e.g. 'notification_channel_description'
/// A notification action which triggers a App navigation event
const notificationChannelDescription = '';

/// The [NotificationAppLaunchDetails] class contains
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  log('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    log('notification action tapped with input: ${notificationResponse.input}');
  }
}

/// The [NotificationService] class contains
class NotificationService {
  /// Initialize the [FlutterLocalNotificationsPlugin] package
  static Future<void> init() async {
    const initializationSettingsAndroid = AndroidInitializationSettings(
        // TODO: add your notification icon name e.g. 'app_icon'
      '',
    );

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    final initializationSettingsDarwin = DarwinInitializationSettings(
      onDidReceiveLocalNotification: (
        int id,
        String? title,
        String? body,
        String? payload,
      ) async {
        didReceiveLocalNotificationStream.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },
    );
    final initializationSettingsLinux = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      // TODO: add your notification icon name from assets e.g. 'app_icon'
      defaultIcon: AssetsLinuxIcon(''),
    );
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  /// The API to show notifications
  static Future<void> onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    final payload = notificationResponse.payload;

    try {
    // TODO: here add your logic to handle notification
    // by sending the user to a specific page or
    // showing a dialog or something else
    } catch (e) {
    // TODO: handle error
    // by showing a dialog or something else
    }
     
    }
    switch (notificationResponse.notificationResponseType) {
      case NotificationResponseType.selectedNotification:
        selectNotificationStream.add(notificationResponse.payload);
      case NotificationResponseType.selectedNotificationAction:
        if (notificationResponse.actionId == navigationActionId) {
          selectNotificationStream.add(notificationResponse.payload);
        }
    }
  }

  /// Show a notification after every second with the first
  static Future<void> requestNotificationPermission() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .requestNotificationsPermission();
    }

    if (Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  /// Show a notification after every second with the first
  AndroidNotificationDetails androidNotificationDetails =
      const AndroidNotificationDetails(
    notificationChannel,
    notificationChannelName,
    channelDescription: notificationChannelDescription,
    importance: Importance.max,
    priority: Priority.high,
    visibility: NotificationVisibility.public,
    // sound: RawResourceAndroidNotificationSound('test'),
  );
}

/// The [NotificationAppLaunchDetails] class contains
/// details about the notification
class ReceivedNotification {
  /// Constructs an instance of [NotificationAppLaunchDetails] from a map
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  /// The id of the notification
  final int id;

  /// The title of the notification
  final String? title;

  /// The body of the notification
  final String? body;

  /// The payload associated with the notification
  final String? payload;
}

// String convertToJsonString(String input) {
//   final unquotedKeyPattern = RegExp(r'(\w+)(?=:)', multiLine: true);
//   final valuePattern = RegExp(r'(?<=:)([^,}\n]+)', multiLine: true);

//   String jsonLikeString = input.replaceAllMapped(unquotedKeyPattern, (match) {
//     return '"${match.group(1)}"';
//   });

//   jsonLikeString = jsonLikeString.replaceAllMapped(valuePattern, (match) {
//     final value = match.group(0)!.trim();
//     if (value == 'true' || value == 'false' || value == 'null') {
//       return value;
//     } else if (int.tryParse(value) != null || double.tryParse(value) != null) {
//       return value;
//     } else {
//       return '"$value"';
//     }
//   });

//   return jsonLikeString;
// }

///
String convertToJsonString(String input) {
  var jsonLikeString = input;

  jsonLikeString = jsonLikeString
      .replaceAllMapped(RegExp(r'(\w+): ([^,}]+)(?=, |})'), (match) {
    final key = match.group(1);
    final value = match.group(2);
    dynamic parsedValue;

    if (value == 'true' || value == 'false') {
      parsedValue = value == 'true';
    } else if (value == 'null') {
      parsedValue = null;
    } else {
      try {
        parsedValue = json.decode(value!);
      } catch (e) {
        parsedValue = '"$value"';
      }
    }

    return '"$key": $parsedValue';
  });

  return jsonLikeString;
}
