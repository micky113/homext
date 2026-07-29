import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'core/utils/constants.dart';
import 'core/services/notification_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/guard/presentation/providers/guard_provider.dart';
import 'features/resident/presentation/providers/resident_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try initializing Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppConstants.useMockData = false; // Disable mock mode if real Firebase config succeeds
    developer.log("Firebase initialized successfully! Running in Live Database mode.");
  } catch (e) {
    developer.log(
      "Firebase initialization failed: $e.\n"
      "Falling back to Local Simulation/Mock Mode."
    );
    AppConstants.useMockData = true;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<GuardProvider>(
          create: (_) => GuardProvider(),
        ),
        ChangeNotifierProvider<ResidentProvider>(
          create: (_) => ResidentProvider(),
        ),
      ],
      child: const AppRouterView(),
    );
  }
}

class AppRouterView extends StatefulWidget {
  const AppRouterView({super.key});

  @override
  State<AppRouterView> createState() => _AppRouterViewState();
}

class _AppRouterViewState extends State<AppRouterView> {
  late final GoRouter _router;
  final NotificationService _notificationService = NotificationService();
  bool _notificationServiceInitialized = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _router = AppRouter.createRouter(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    // Trigger Notification setup once a user successfully logs in
    if (user != null && !_notificationServiceInitialized) {
      _notificationServiceInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _notificationService.initialize(
          onIncomingNotification: (payload) {
            developer.log("FCM Payload received in foreground: $payload");
            // If the app is active in the foreground, Firestore real-time stream
            // naturally updates the ResidentProvider's activeAlert state.
          },
        );

        final token = await _notificationService.getDeviceToken();
        if (token != null) {
          await authProvider.updateFcmToken(token);
        }
      });
    } else if (user == null && _notificationServiceInitialized) {
      // Reset tracker on logout
      _notificationServiceInitialized = false;
    }

    return MaterialApp.router(
      title: 'MyGate Homext',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Automatically matches OS light/dark theme!
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
