import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/resident_provider.dart';
import '../widgets/incoming_alert_dialog.dart';
import '../widgets/invite_visitor_dialog.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ResidentDashboardScreen extends StatefulWidget {
  const ResidentDashboardScreen({super.key});

  @override
  State<ResidentDashboardScreen> createState() => _ResidentDashboardScreenState();
}

class _ResidentDashboardScreenState extends State<ResidentDashboardScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final authProvider = Provider.of<AuthProvider>(context);
      final residentProvider = Provider.of<ResidentProvider>(context, listen: false);
      final user = authProvider.currentUser;
      if (user != null) {
        residentProvider.initialize(user.uid, user.flatNumber, user.metadata['societyId'] ?? '');
      }
      _initialized = true;
    }
  }

  void _triggerIncomingAlertOverlay(BuildContext context, dynamic alert) {
    final residentProvider = Provider.of<ResidentProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => IncomingAlertDialog(checkin: alert),
    ).then((_) {
      if (mounted) {
        residentProvider.clearActiveAlert();
      }
    });
  }

  void _showEditProfileDialog(BuildContext context, UserEntity user) {
    final nameController = TextEditingController(text: user.name);
    final flatController = TextEditingController(text: user.flatNumber);
    final formKey = GlobalKey<FormState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        bool isUpdating = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Edit Profile Details',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Your Name',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: flatController,
                        decoration: const InputDecoration(
                          labelText: 'Flat / House Number',
                          prefixIcon: Icon(Icons.home_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your flat number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      isUpdating
                          ? const Center(child: CircularProgressIndicator())
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      setDialogState(() {
                                        isUpdating = true;
                                      });
                                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                      final success = await authProvider.updateProfile(
                                        name: nameController.text.trim(),
                                        flatNumber: flatController.text.trim(),
                                      );
                                      if (success && context.mounted) {
                                        final residentProvider = Provider.of<ResidentProvider>(context, listen: false);
                                        residentProvider.initialize(user.uid, flatController.text.trim(), user.metadata['societyId'] ?? '');
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Profile updated successfully!'),
                                            backgroundColor: AppColors.secondary,
                                          ),
                                        );
                                      } else if (context.mounted) {
                                        setDialogState(() {
                                          isUpdating = false;
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(authProvider.errorMessage ?? 'Failed to update profile'),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    minimumSize: const Size(100, 44),
                                  ),
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final residentProvider = Provider.of<ResidentProvider>(context);
    final user = authProvider.currentUser;

    // Listen for incoming alerts and show the modal instantly
    if (residentProvider.activeAlert != null) {
      final alert = residentProvider.activeAlert!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerIncomingAlertOverlay(context, alert);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Resident Hub',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
        ),
      ),
      drawer: const AppDrawer(),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                residentProvider.initialize(user.uid, user.flatNumber, user.metadata['societyId'] ?? '');
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome Header Card
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome back,',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withAlpha(200),
                                        ),
                                      ),
                                      Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _showEditProfileDialog(context, user),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white.withAlpha(40),
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.edit_rounded, size: 20),
                                  tooltip: 'Edit Profile',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildBadge(Icons.home_rounded, 'Flat ${user.flatNumber}'),
                                _buildBadge(Icons.verified_user_rounded, 'Resident'),
                                _buildBadge(Icons.business_rounded, user.metadata['societyName'] ?? 'Your Society'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context,
                            title: 'Invite Guest',
                            subtitle: 'Pre-approve entry',
                            icon: Icons.person_add_rounded,
                            gradient: AppColors.primaryGradient,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => InviteVisitorDialog(
                                  userId: user.uid,
                                  flatNumber: user.flatNumber,
                                  hostName: user.name,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Active Invites Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pre-approved Guests',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                        ),
                        const Icon(Icons.qr_code_rounded, color: AppColors.primary),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    residentProvider.isLoading
                        ? const Center(child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ))
                        : residentProvider.invites.isEmpty
                            ? _buildEmptyState(
                                context,
                                icon: Icons.airplane_ticket_outlined,
                                message: 'No pre-approved invites yet.',
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: residentProvider.invites.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final invite = residentProvider.invites[index];
                                  return Card(
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppColors.primary.withAlpha(20),
                                        child: const Icon(Icons.vpn_key_rounded, color: AppColors.primary),
                                      ),
                                      title: Text(
                                        invite.visitorName,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'Purpose: ${invite.purpose} • ${invite.inviteDate.day}/${invite.inviteDate.month}/${invite.inviteDate.year}',
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withAlpha(25),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          invite.inviteCode,
                                          style: const TextStyle(
                                            color: AppColors.primaryLight,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                    const SizedBox(height: 32),
                    _buildHistoryList(context, residentProvider),
                    const SizedBox(height: 32),
                    _buildSocietySection(context, residentProvider, user),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withAlpha(40),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.white),
          ],
        ),
      ),
    );
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

  Widget _buildHistoryList(BuildContext context, ResidentProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Visitor Entry History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
            ),
            const Icon(Icons.history_rounded, color: AppColors.secondary),
          ],
        ),
        const SizedBox(height: 12),
        provider.history.isEmpty
            ? _buildEmptyState(
                context,
                icon: Icons.history_rounded,
                message: 'No visitor entries recorded yet.',
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.history.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final log = provider.history[index];
                  final statusColor = log.status == 'APPROVED'
                      ? AppColors.secondary
                      : log.status == 'EXITED'
                          ? Colors.grey
                          : log.status == 'DENIED'
                              ? AppColors.error
                              : AppColors.warning;
                          
                  final statusIcon = log.status == 'APPROVED'
                      ? Icons.check_circle_outline_rounded
                      : log.status == 'EXITED'
                          ? Icons.exit_to_app_rounded
                          : log.status == 'DENIED'
                              ? Icons.cancel_outlined
                              : Icons.hourglass_empty_rounded;

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: statusColor.withAlpha(15),
                        child: Icon(statusIcon, color: statusColor),
                      ),
                      title: Text(
                        log.visitorName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Purpose: ${log.purpose} • Gate: ${log.gateNumber}\nTime: ${_formatTime(log.timestamp)}',
                      ),
                      isThreeLine: true,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor.withAlpha(80)),
                        ),
                        child: Text(
                          log.status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    return '${time.day}/${time.month} $hour:$min';
  }

  Widget _buildSocietySection(BuildContext context, ResidentProvider provider, UserEntity user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notices = provider.notices;
    
    final dues = double.tryParse(user.metadata['pendingDues']?.toString() ?? '0') ?? 0.0;
    
    // We will render up to 10 announcements dynamically from the notices list

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Society & Notices',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
            ),
            const Icon(Icons.business_rounded, color: AppColors.primary),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => GoRouter.of(context).push('/society-details'),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.glassBorder : AppColors.lightSurfaceLight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 30 : 10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: dues > 0 
                            ? AppColors.error.withAlpha(20) 
                            : AppColors.secondary.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        dues > 0 ? Icons.payment_rounded : Icons.check_circle_rounded,
                        color: dues > 0 ? AppColors.error : AppColors.secondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Maintenance Dues',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            dues > 0 ? '₹${dues.toStringAsFixed(0)} Pending' : 'All Dues Paid',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: dues > 0 ? AppColors.error : AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.campaign_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Announcements',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (notices.isEmpty)
                            const Text(
                              'No announcements posted yet',
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            )
                          else
                            ...notices.take(10).map((notice) {
                              final noticeIndex = notices.indexOf(notice);
                              final limitCount = notices.take(10).length;
                              final isLast = noticeIndex == limitCount - 1;
                              final dateStr = '${notice.timestamp.day}/${notice.timestamp.month}/${notice.timestamp.year}';
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notice.title,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        dateStr,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notice.content,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (!isLast) ...[
                                    const SizedBox(height: 8),
                                    Divider(color: (isDark ? AppColors.glassBorder : Colors.grey[200])?.withAlpha(80)),
                                    const SizedBox(height: 8),
                                  ],
                                ],
                              );
                            }),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'View Notice Board & Dues',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
