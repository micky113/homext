import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) return const SizedBox.shrink();

    final isResident = user.role == 'RESIDENT';
    final isGuard = user.role == 'GUARD';

    final societyName = user.metadata['societyName'] ?? 'Homext Heights';
    final subtitle = isResident
        ? 'Resident • Flat ${user.metadata['flatNumber'] ?? ""}'
        : isGuard
            ? 'Guard • ${user.metadata['gateNumber'] ?? ""}'
            : 'Society Admin';

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppColors.accentGradient,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            accountName: Text(
              user.name,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            accountEmail: Text(
              '$subtitle • $societyName',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded, color: AppColors.primaryLight),
            title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: AppColors.error.withAlpha(20),
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close drawer
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text(
                      'Confirm Logout',
                      style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
                    ),
                    content: const Text('Are you sure you want to log out of your session?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          authProvider.logout();
                          context.go('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
