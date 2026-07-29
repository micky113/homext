import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/guard_provider.dart';
import '../widgets/visitor_checkin_form.dart';

class GuardDashboardScreen extends StatefulWidget {
  const GuardDashboardScreen({super.key});

  @override
  State<GuardDashboardScreen> createState() => _GuardDashboardScreenState();
}

class _GuardDashboardScreenState extends State<GuardDashboardScreen> {
  int _activeTab = 0; // 0 = Log New Entry, 1 = Verify Pre-Approved Code
  final _codeController = TextEditingController();
  final _codeFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleVerifyCode(GuardProvider provider, String guardId, String gateNumber) async {
    if (_codeFormKey.currentState!.validate()) {
      final code = _codeController.text.trim();
      final success = await provider.checkInPreApprovedVisitor(
        inviteCode: code,
        gateNumber: gateNumber,
        guardId: guardId,
      );

      if (success && mounted) {
        _codeController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visitor pre-approval verified! Entry APPROVED!'),
            backgroundColor: AppColors.secondary,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Verification failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _quickCheckInInvite(GuardProvider provider, String inviteCode, String guardId, String gateNumber) async {
    final success = await provider.checkInPreApprovedVisitor(
      inviteCode: inviteCode,
      gateNumber: gateNumber,
      guardId: guardId,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invite code $inviteCode checked in! Entry APPROVED!'),
          backgroundColor: AppColors.secondary,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Verification failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final guardProvider = Provider.of<GuardProvider>(context);
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Check if layout should be wide (desktop/tablet) or narrow (mobile)
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guard Terminal',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              authProvider.logout();
              context.go('/login');
            },
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          )
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Guard Profile Header
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.guardGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white.withAlpha(50),
                            child: const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _buildBadge(Icons.location_on_rounded, user.gateNumber),
                                    const SizedBox(width: 8),
                                    _buildBadge(Icons.shield_rounded, 'Active Guard'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Responsive body split
                  Expanded(
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Column: Navigation controls + Form
                              SizedBox(
                                width: 360,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _buildTabToggler(isDark),
                                      const SizedBox(height: 12),
                                      _activeTab == 0
                                          ? VisitorCheckinForm(
                                              guardId: user.uid,
                                              gateNumber: user.gateNumber,
                                            )
                                          : _buildVerifyCodeForm(guardProvider, user.uid, user.gateNumber, isDark),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Right Column: Live Feed logs
                              Expanded(
                                child: _buildCheckinsList(context, guardProvider),
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildTabToggler(isDark),
                                const SizedBox(height: 12),
                                _activeTab == 0
                                    ? VisitorCheckinForm(
                                        guardId: user.uid,
                                        gateNumber: user.gateNumber,
                                      )
                                    : _buildVerifyCodeForm(guardProvider, user.uid, user.gateNumber, isDark),
                                const SizedBox(height: 24),
                                SizedBox(
                                  height: 400,
                                  child: _buildCheckinsList(context, guardProvider),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTabToggler(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _activeTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _activeTab == 0 
                      ? (isDark ? Colors.white.withAlpha(30) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _activeTab == 0 && !isDark
                      ? [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Text(
                  'Log New Entry',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: _activeTab == 0 ? AppColors.secondary : (isDark ? Colors.grey[400] : Colors.grey[700]),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _activeTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _activeTab == 1 
                      ? (isDark ? Colors.white.withAlpha(30) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _activeTab == 1 && !isDark
                      ? [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Text(
                  'Verify Code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: _activeTab == 1 ? AppColors.secondary : (isDark ? Colors.grey[400] : Colors.grey[700]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyCodeForm(GuardProvider provider, String guardId, String gateNumber, bool isDark) {
    return Card(
      elevation: isDark ? 0 : 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Verify Invite Code',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
            ),
            const SizedBox(height: 12),
            Form(
              key: _codeFormKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Invite Code',
                        hintText: 'e.g. MG-1243',
                        prefixIcon: Icon(Icons.qr_code_rounded),
                        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter code';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 52,
                    width: 64,
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () => _handleVerifyCode(provider, guardId, gateNumber),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Icon(Icons.check_circle_outline_rounded),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Active Pre-approved Invites',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.0,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            provider.preApprovedInvites.isEmpty
                ? _buildSubEmptyState('No active pre-approvals.')
                : Container(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: provider.preApprovedInvites.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final invite = provider.preApprovedInvites[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkBg : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? AppColors.glassBorder : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      invite.visitorName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Flat ${invite.flatNumber} • ${invite.purpose}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withAlpha(20),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        invite.inviteCode,
                                        style: const TextStyle(
                                          color: AppColors.secondary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: provider.isLoading
                                    ? null
                                    : () => _quickCheckInInvite(provider, invite.inviteCode, guardId, gateNumber),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  minimumSize: Size.zero,
                                  backgroundColor: AppColors.secondary.withAlpha(25),
                                  foregroundColor: AppColors.secondary,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Check In',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubEmptyState(String msg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.airplane_ticket_outlined, size: 36, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
          const SizedBox(height: 8),
          Text(
            msg,
            style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinsList(BuildContext context, GuardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Live Society Feed',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.wifi_tethering_rounded, color: AppColors.secondary, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Live Monitoring',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: provider.checkins.isEmpty
              ? _buildEmptyState(
                  context,
                  icon: Icons.history_rounded,
                  message: 'No check-ins logged for today.',
                )
              : ListView.separated(
                  itemCount: provider.checkins.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final log = provider.checkins[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(log.status).withAlpha(15),
                          child: Icon(
                            _getStatusIcon(log.status),
                            color: _getStatusColor(log.status),
                          ),
                        ),
                        title: Text(
                          log.visitorName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Flat: ${log.flatNumber} • Purpose: ${log.purpose}\n${log.gateNumber} • ${_formatTime(log.timestamp)}',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(log.status).withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getStatusColor(log.status).withAlpha(80),
                                ),
                              ),
                              child: Text(
                                log.status,
                                style: TextStyle(
                                  color: _getStatusColor(log.status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            if (log.status == 'APPROVED') ...[
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => provider.exitVisitor(log.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error.withAlpha(20),
                                  foregroundColor: AppColors.error,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.exit_to_app_rounded, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'Exit',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'APPROVED':
        return AppColors.secondary;
      case 'DENIED':
        return AppColors.error;
      case 'PENDING':
      default:
        return AppColors.warning;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'APPROVED':
        return Icons.check_circle_outline_rounded;
      case 'DENIED':
        return Icons.cancel_outlined;
      case 'PENDING':
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }

  Widget _buildEmptyState(BuildContext context, {required IconData icon, required String message}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.glassBorder : AppColors.lightSurfaceLight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
