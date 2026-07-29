import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/constants.dart';
import 'mock_data_service.dart';

// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background processing
  await Firebase.initializeApp();
  developer.log("Handling background FCM message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final MockDataService _mockData = MockDataService();

  // Initialize notifications
  Future<void> initialize({
    required Function(Map<String, dynamic> payload) onIncomingNotification,
  }) async {
    if (AppConstants.useMockData) {
      developer.log("Initializing Mock Notification Service...");
      // Subscribe to mock stream to simulate incoming notifications
      _mockData.incomingAlertsStream.listen((checkin) {
        developer.log("Simulating Incoming FCM payload for visitor: ${checkin.visitorName}");
        onIncomingNotification({
          'type': 'VISITOR_ALERT',
          'checkinId': checkin.id,
          'visitorName': checkin.visitorName,
          'purpose': checkin.purpose,
          'flatNumber': checkin.flatNumber,
        });
      });
      return;
    }

    try {
      // 1. Request notification permissions
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      developer.log('User notification authorization status: ${settings.authorizationStatus}');

      // 2. Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log('Got a message whilst in the foreground!');
        developer.log('Message data: ${message.data}');

        if (message.notification != null) {
          developer.log('Message also contained a notification: ${message.notification?.title}');
        }
        
        onIncomingNotification(message.data);
      });

      // 4. Handle notification click when app is opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        developer.log('App opened from background via notification: ${message.data}');
        onIncomingNotification(message.data);
      });

      // 5. Handle notification click when app is opened from terminated state
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        developer.log('App opened from terminated state via notification: ${initialMessage.data}');
        onIncomingNotification(initialMessage.data);
      }
    } catch (e) {
      developer.log("FCM initialization failed: $e. Falling back to mock notification service.");
      // Fallback if Firebase throws due to missing config
      AppConstants.useMockData = true;
      initialize(onIncomingNotification: onIncomingNotification);
    }
  }

  // Fetch token and save it
  Future<String?> getDeviceToken() async {
    if (AppConstants.useMockData) {
      return "mock-fcm-device-token-12345";
    }

    try {
      String? token = await _fcm.getToken();
      developer.log("FCM Device Token: $token");
      return token;
    } catch (e) {
      developer.log("Failed to get FCM Token: $e");
      return "mock-fcm-device-token-failed";
    }
  }
}
