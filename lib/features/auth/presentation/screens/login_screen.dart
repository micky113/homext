import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _handleSendOtp() async {
    if (_phoneFormKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Ensure phone number starts with +91 (default Indian country code)
      var phone = _phoneController.text.trim();
      if (!phone.startsWith('+')) {
        phone = '+91$phone';
      }

      final success = await authProvider.sendOtp(phone);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to send OTP'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleVerifyOtp() async {
    if (_otpFormKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.verifyOtp(_otpController.text.trim());

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'OTP verification failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _quickLogin(String phone) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Step 1: Send OTP
    _phoneController.text = phone.replaceAll('+91 ', '');
    final sent = await authProvider.sendOtp(phone.replaceAll(' ', ''));
    if (!sent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Quick login failed at OTP request'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Step 2: Auto-verify OTP (since it's a demo shortcut, autofill the mock OTP)
    _otpController.text = AppConstants.demoOtp;
    final verified = await authProvider.verifyOtp(AppConstants.demoOtp);
    if (!verified && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Quick login failed at OTP verification'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark 
              ? const LinearGradient(
                  colors: [AppColors.darkBg, Color(0xFF020617)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : const LinearGradient(
                  colors: [AppColors.lightBg, Color(0xFFE2E8F0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Icon / Logo
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.accentGradient,
                      ),
                      child: const Icon(
                        Icons.security_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // App Title
                  Text(
                    'MyGate Homext',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    'Role-Based Gate Management Portal',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                  ),
                  const SizedBox(height: 40),

                  // Login Form Card
                  Card(
                    elevation: isDark ? 0 : 4,
                    shadowColor: Colors.black.withAlpha(20),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: authProvider.codeSent
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: _buildPhoneInputForm(authProvider),
                        secondChild: _buildOtpInputForm(authProvider),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Quick Demo Shortcut section (Only show if not verifying a sent code)
                  if (!authProvider.codeSent)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: isDark ? AppColors.glassBorder : AppColors.lightTextMuted.withAlpha(50),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'DEMO SHORTCUTS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: isDark ? AppColors.glassBorder : AppColors.lightTextMuted.withAlpha(50),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () => _quickLogin(AppConstants.demoResidentPhone),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(
                                    color: AppColors.primary.withAlpha(100),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.home_rounded, color: AppColors.primaryLight),
                                label: const Text(
                                  'Resident Portal',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryLight,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () => _quickLogin(AppConstants.demoGuardPhone),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(
                                    color: AppColors.secondary.withAlpha(100),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.secondary),
                                label: const Text(
                                  'Guard Terminal',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Phase 1 Widget: Phone Number entry form
  Widget _buildPhoneInputForm(AuthProvider authProvider) {
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sign In with Mobile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your registered mobile number to receive a one-time OTP.',
            style: TextStyle(fontSize: 13, color: AppColors.darkTextSecondary),
          ),
          const SizedBox(height: 24),

          // Phone field
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixText: '+91 ',
              prefixIcon: Icon(Icons.phone_iphone_rounded),
              hintText: '98765 43210',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              final clean = value.replaceAll(RegExp(r'\s+'), '');
              if (clean.length < 10) {
                return 'Please enter a valid 10-digit number';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          authProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                )
              : ElevatedButton(
                  onPressed: _handleSendOtp,
                  child: const Text('Get OTP'),
                ),
        ],
      ),
    );
  }

  // Phase 2 Widget: OTP entry form
  Widget _buildOtpInputForm(AuthProvider authProvider) {
    return Form(
      key: _otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => authProvider.resetPhoneAuthState(),
                icon: const Icon(Icons.arrow_back_rounded),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 8),
              Text(
                'Verify OTP',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the 6-digit verification code sent to ${authProvider.phoneNumber}.',
            style: const TextStyle(fontSize: 13, color: AppColors.darkTextSecondary),
          ),
          const SizedBox(height: 24),

          // OTP field
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8.0,
            ),
            decoration: const InputDecoration(
              labelText: 'OTP Verification Code',
              counterText: '',
              prefixIcon: Icon(Icons.lock_clock_outlined),
              hintText: '------',
              hintStyle: TextStyle(letterSpacing: 8.0),
            ),
            validator: (value) {
              if (value == null || value.trim().length != 6) {
                return 'Please enter the 6-digit code';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          authProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                )
              : ElevatedButton(
                  onPressed: _handleVerifyOtp,
                  child: const Text('Verify & Sign In'),
                ),
        ],
      ),
    );
  }
}
