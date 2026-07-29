import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/guard/presentation/screens/guard_dashboard_screen.dart';
import '../../features/resident/presentation/screens/resident_dashboard_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login';

        // 1. If not logged in, force navigation to login screen
        if (!isLoggedIn) {
          return isLoggingIn ? null : '/login';
        }

        // 2. If logged in, fetch user details
        final user = authProvider.currentUser;
        if (user == null) {
          // Auth state says authenticated but user record not loaded yet
          return null; 
        }

        final role = user.role;

        // 3. Prevent logged in user from visiting login page
        if (isLoggingIn) {
          if (role == 'RESIDENT') return '/resident/dashboard';
          if (role == 'GUARD') return '/guard/dashboard';
        }

        // 4. Role-based routing guards
        if (state.matchedLocation.startsWith('/resident') && role != 'RESIDENT') {
          return '/guard/dashboard';
        }

        if (state.matchedLocation.startsWith('/guard') && role != 'GUARD') {
          return '/resident/dashboard';
        }

        // Allow routing if guards pass
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/resident/dashboard',
          builder: (context, state) => const ResidentDashboardScreen(),
        ),
        GoRoute(
          path: '/guard/dashboard',
          builder: (context, state) => const GuardDashboardScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Routing error: ${state.error}'),
        ),
      ),
    );
  }
}
