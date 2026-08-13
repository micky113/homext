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

  static final Map<String, _BrandInfo> _brandMapping = {
    'swiggy': _BrandInfo(
      domain: 'swiggy.com',
      primaryColor: const Color(0xFFFC8019),
      fallbackTextColor: Colors.white,
    ),
    'zomato': _BrandInfo(
      domain: 'zomato.com',
      primaryColor: const Color(0xFFCB202D),
      fallbackTextColor: Colors.white,
    ),
    'amazon': _BrandInfo(
      domain: 'amazon.in',
      primaryColor: const Color(0xFF232F3E),
      fallbackTextColor: const Color(0xFFFF9900),
    ),
    'uber': _BrandInfo(
      domain: 'uber.com',
      primaryColor: Colors.black,
      fallbackTextColor: Colors.white,
    ),
    'flipkart': _BrandInfo(
      domain: 'flipkart.com',
      primaryColor: const Color(0xFF2874F0),
      fallbackTextColor: const Color(0xFFFFE11B),
    ),
    'dunzo': _BrandInfo(
      domain: 'dunzo.com',
      primaryColor: const Color(0xFF00E676),
      fallbackTextColor: Colors.black,
    ),
    'urban company': _BrandInfo(
      domain: 'urbancompany.com',
      primaryColor: Colors.black,
      fallbackTextColor: Colors.white,
    ),
    'dhl': _BrandInfo(
      domain: 'dhl.com',
      primaryColor: const Color(0xFFFFCC00),
      fallbackTextColor: const Color(0xFFD40511),
    ),
    'bluedart': _BrandInfo(
      domain: 'bluedart.com',
      primaryColor: const Color(0xFF003399),
      fallbackTextColor: const Color(0xFFFFCC00),
    ),
    'fedex': _BrandInfo(
      domain: 'fedex.com',
      primaryColor: const Color(0xFFFF6200),
      fallbackTextColor: Colors.white,
    ),
    'blinkit': _BrandInfo(
      domain: 'blinkit.com',
      primaryColor: const Color(0xFFF7EC13),
      fallbackTextColor: Colors.black,
    ),
    'blink it': _BrandInfo(
      domain: 'blinkit.com',
      primaryColor: const Color(0xFFF7EC13),
      fallbackTextColor: Colors.black,
    ),
    'ola': _BrandInfo(
      domain: 'olacabs.com',
      primaryColor: const Color(0xFFC6DB1A),
      fallbackTextColor: Colors.black,
    ),
    'ola cabs': _BrandInfo(
      domain: 'olacabs.com',
      primaryColor: const Color(0xFFC6DB1A),
      fallbackTextColor: Colors.black,
    ),
    'rapido': _BrandInfo(
      domain: 'rapido.bike',
      primaryColor: const Color(0xFFFFDD00),
      fallbackTextColor: Colors.black,
    ),
  };

  String? _detectBrandKey(String name, String purpose) {
    final lowerName = name.toLowerCase();
    final lowerPurpose = purpose.toLowerCase();
    for (final key in _brandMapping.keys) {
      if (lowerName.contains(key) || lowerPurpose.contains(key)) {
        return key;
      }
    }
    return null;
  }

  Widget _buildBrandLogo(String brandKey) {
    switch (brandKey.toLowerCase()) {
      case 'rapido':
        return Container(
          color: const Color(0xFFFFDD00),
          child: const Center(
            child: Text(
              'rapido',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                fontFamily: 'Outfit',
                letterSpacing: -0.5,
              ),
            ),
          ),
        );
      case 'ola':
      case 'ola cabs':
        return Container(
          color: const Color(0xFFC6DB1A),
          child: const Center(
            child: Text(
              'ola',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                fontFamily: 'Outfit',
                letterSpacing: -1,
              ),
            ),
          ),
        );
      case 'blinkit':
      case 'blink it':
        return Container(
          color: const Color(0xFFF7EC13),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'blink',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    fontFamily: 'Outfit',
                  ),
                ),
                Text(
                  'it',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
        );
      case 'swiggy':
        return Container(
          color: const Color(0xFFFC8019),
          child: const Center(
            child: Text(
              'S',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                fontStyle: FontStyle.italic,
                fontFamily: 'Outfit',
              ),
            ),
          ),
        );
      case 'zomato':
        return Container(
          color: const Color(0xFFCB202D),
          child: const Center(
            child: Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        );
      case 'amazon':
        return Container(
          color: const Color(0xFF232F3E),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'a',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    height: 1.0,
                    fontFamily: 'Outfit',
                  ),
                ),
                Icon(
                  Icons.subdirectory_arrow_right_rounded,
                  color: Color(0xFFFF9900),
                  size: 10,
                ),
              ],
            ),
          ),
        );
      case 'uber':
        return Container(
          color: Colors.black,
          child: const Center(
            child: Text(
              'U',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                fontFamily: 'Outfit',
                letterSpacing: -1,
              ),
            ),
          ),
        );
      case 'flipkart':
        return Container(
          color: const Color(0xFF2874F0),
          child: const Center(
            child: Icon(
              Icons.shopping_cart_rounded,
              color: Color(0xFFFFE11B),
              size: 22,
            ),
          ),
        );
      case 'dunzo':
        return Container(
          color: const Color(0xFF0F0F14),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'd',
                  style: TextStyle(
                    color: Color(0xFF00E676),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    fontFamily: 'Outfit',
                  ),
                ),
                Icon(
                  Icons.flash_on_rounded,
                  color: Color(0xFF00E676),
                  size: 12,
                ),
              ],
            ),
          ),
        );
      case 'urban company':
        return Container(
          color: Colors.black,
          child: const Center(
            child: Text(
              'UC',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
                fontFamily: 'Outfit',
              ),
            ),
          ),
        );
      case 'dhl':
        return Container(
          color: const Color(0xFFFFCC00),
          child: const Center(
            child: Text(
              'DHL',
              style: TextStyle(
                color: Color(0xFFD40511),
                fontWeight: FontWeight.w900,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                letterSpacing: -0.5,
              ),
            ),
          ),
        );
      case 'bluedart':
        return Container(
          color: const Color(0xFF003399),
          child: const Center(
            child: Text(
              'BD',
              style: TextStyle(
                color: Color(0xFFFFCC00),
                fontWeight: FontWeight.w900,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      case 'fedex':
        return Container(
          color: Colors.white,
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Fed',
                  style: TextStyle(
                    color: Color(0xFF4D148C),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Ex',
                  style: TextStyle(
                    color: Color(0xFFFF6200),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

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
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        InkWell(
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
                          borderRadius: BorderRadius.circular(16),
                          child: Ink(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withAlpha(30),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_add_rounded, size: 28, color: Colors.white),
                                SizedBox(height: 8),
                                Text(
                                  'Invite Guest',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Pre-approve',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        InkWell(
                          onTap: () {
                            GoRouter.of(context).push('/society-dues');
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Ink(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.secondary, Color(0xFFAD9F8F)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondary.withAlpha(30),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.account_balance_wallet_rounded, size: 28, color: Colors.white),
                                SizedBox(height: 8),
                                Text(
                                  'Society Dues',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Pay & Submit',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            : SizedBox(
                height: 105,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: provider.history.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final log = provider.history[index];
                    debugPrint('Rendering history item name: "${log.visitorName}" | status: "${log.status}"');
                    debugPrint('Brand match for "${log.visitorName}": ${_detectBrandKey(log.visitorName, log.purpose)}');
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

                    // Get initials
                    final initials = log.visitorName.trim().isNotEmpty
                        ? log.visitorName.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                        : '?';

                    final hour = log.timestamp.hour.toString().padLeft(2, '0');
                    final min = log.timestamp.minute.toString().padLeft(2, '0');
                    final timeStr = '$hour:$min';

                    return InkWell(
                      onTap: () {
                        // Show a beautiful detail dialog when tapped
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: Row(
                              children: [
                                Icon(statusIcon, color: statusColor),
                                const SizedBox(width: 8),
                                const Text('Visitor Details', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow(context, 'Name', log.visitorName),
                                _buildDetailRow(context, 'Purpose', log.purpose),
                                _buildDetailRow(context, 'Gate', log.gateNumber),
                                _buildDetailRow(context, 'Time', _formatTime(log.timestamp)),
                                _buildDetailRow(context, 'Status', log.status, color: statusColor),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              children: [
                                (() {
                                  final brandKey = _detectBrandKey(log.visitorName, log.purpose);
                                  if (brandKey != null) {
                                    final brand = _brandMapping[brandKey]!;
                                    return Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: statusColor, width: 2),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(28),
                                        child: Image.network(
                                          'https://logos.hunter.io/${brand.domain}',
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return _buildBrandLogo(brandKey);
                                          },
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Container(
                                              color: brand.primaryColor.withAlpha(50),
                                              child: const Center(
                                                child: SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                  return Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: statusColor.withAlpha(20),
                                      border: Border.all(color: statusColor, width: 2),
                                    ),
                                    child: Center(
                                      child: Text(
                                        initials,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  );
                                })(),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkSurface : Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      statusIcon,
                                      size: 14,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: 68,
                              child: Text(
                                log.visitorName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              timeStr,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                              ),
                            ),
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

  Widget _buildDetailRow(BuildContext context, String label, String value, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color ?? (isDark ? Colors.white : Colors.black87),
                fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
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

class _BrandInfo {
  final String domain;
  final Color primaryColor;
  final Color fallbackTextColor;
  
  _BrandInfo({
    required this.domain,
    required this.primaryColor,
    required this.fallbackTextColor,
  });
}
