import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/scheduler.dart' as sch;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// annotate for vm entry point
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// Handle message
Future<void> handleMessage(RemoteMessage message) async {
  try {
    // TODO: here add your logic to handle notification
    // by sending the user to a specific page or
    // showing a dialog or something else
  } catch (e) {
    // TODO: handle error
    // by showing a dialog or something else
  }
}

/// Firebase notification handler
class FirebaseNotificationHandler {
  /// Constructor
  Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await requestPermission();
    await handleIncomingNotification();
  }

  /// Request permission for notification
  Future<void> requestPermission() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // TODO: handle permission granted
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      // TODO: handle provisional permission granted
    } else {
      // TODO: handle permission denied
    }
  }

  /// Handle incoming notification
  Future<void> handleIncomingNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      await handleMessage(initialMessage);
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    FirebaseMessaging.onMessage.listen(notificationStyle);
  }

  /// Notification style
  Future<void> notificationStyle(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      const androidNotificationDetails = AndroidNotificationDetails(
        '0',
        notificationChannelName,
        channelDescription: notificationChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
      );
      const iosNotificationDetails = DarwinNotificationDetails();
      const notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );
      await flutterLocalNotificationsPlugin.show(
        0,
        notification.title,
        notification.body,
        notificationDetails,
        payload: message.data.toString(),
      );
    }
  }
}
