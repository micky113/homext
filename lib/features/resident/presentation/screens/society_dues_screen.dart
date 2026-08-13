import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/resident_provider.dart';

class SocietyDuesScreen extends StatefulWidget {
  const SocietyDuesScreen({super.key});

  @override
  State<SocietyDuesScreen> createState() => _SocietyDuesScreenState();
}

class _SocietyDuesScreenState extends State<SocietyDuesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _remarksController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext context, String userId) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final provider = Provider.of<ResidentProvider>(context, listen: false);
      try {
        await provider.submitPaymentVerification(
          userId: userId,
          remarks: _referenceController.text.trim(),
          amountPaid: _amountController.text.trim(),
        );

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment proof submitted successfully! Pending approval from admin.'),
            backgroundColor: AppColors.secondary,
          ),
        );
        context.pop();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final metadata = user.metadata;
    final pendingDues = metadata['pendingDues']?.toString() ?? '0';
    final paymentStatus = metadata['paymentStatus']?.toString() ?? 'unpaid';
    final pendingPaymentAmount = metadata['pendingPaymentAmount']?.toString() ?? '0';

    // Autofill outstanding dues if not already filled
    if (_amountController.text.isEmpty && pendingDues != '0') {
      _amountController.text = pendingDues;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Society Dues',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Outstanding Dues Summary Card
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(20),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'OUTSTANDING BALANCE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withAlpha(200),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹$pendingDues',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (paymentStatus == 'pending_confirmation')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withAlpha(40),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.amber.withAlpha(100)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.hourglass_empty_rounded, color: Colors.amber, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'Approval Pending: ₹$pendingPaymentAmount',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (pendingDues == '0')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withAlpha(40),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppColors.secondary.withAlpha(100)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 14),
                            const SizedBox(width: 6),
                            const Text(
                              'All Dues Paid',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(40),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppColors.error.withAlpha(100)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Payment Pending',
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Scan to Pay Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: isDark ? 0 : 2,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Scan to Pay via UPI',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Scan this QR code with any UPI app to transfer dues.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 20),

                    // Custom vector QR code mockup
                    Container(
                      width: 200,
                      height: 200,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!, width: 2),
                      ),
                      child: Stack(
                        children: [
                          // Vector representation of a QR code
                          CustomPaint(
                            size: const Size(176, 176),
                            painter: _QrCodePainter(isDark: false),
                          ),
                          // Small brand logo overlay
                          Center(
                            child: Container(
                              width: 36,
                              height: 36,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(20),
                                    blurRadius: 4,
                                  )
                                ],
                              ),
                              child: Image.network(
                                'https://logos.hunter.io/swiggy.com',
                                width: 28,
                                height: 28,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.account_balance_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // UPI Apps Banner
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet_rounded, color: Colors.grey, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Accepted: GPay, PhonePe, Paytm, BHIM & more',
                          style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bank Details Section
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: isDark ? 0 : 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Direct Bank Transfer Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildBankDetailRow(context, 'Bank Name', 'HDFC Bank Ltd.'),
                    _buildBankDetailRow(context, 'Account Name', 'Homext Resident Welfare Association'),
                    _buildBankDetailRow(context, 'Account Number', '50200048192837'),
                    _buildBankDetailRow(context, 'IFSC Code', 'HDFC0001245'),
                    _buildBankDetailRow(context, 'Branch', 'Green Park, New Delhi'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Payment Submission Form
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: isDark ? 0 : 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Submit Payment Proof',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Enter details of your transaction below for admin validation.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 20),

                      // Amount Field
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount Paid (₹)',
                          prefixIcon: Icon(Icons.currency_rupee_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the amount paid';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Transaction ID Field
                      TextFormField(
                        controller: _referenceController,
                        decoration: const InputDecoration(
                          labelText: 'Transaction ID / UPI Reference No',
                          prefixIcon: Icon(Icons.receipt_long_rounded),
                          hintText: 'e.g. UPI Ref 3829104829',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the transaction reference number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      _isSubmitting
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: () => _handleSubmit(context, user.uid),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text(
                                'Submit Verification Proof',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDetailRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrCodePainter extends CustomPainter {
  final bool isDark;
  _QrCodePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Draw QR corners (three position detection patterns)
    // 1. Top Left
    canvas.drawRect(const Rect.fromLTWH(0, 0, 48, 48), paint);
    canvas.drawRect(const Rect.fromLTWH(8, 8, 32, 32), Paint()..color = Colors.white);
    canvas.drawRect(const Rect.fromLTWH(14, 14, 20, 20), paint);

    // 2. Top Right
    canvas.drawRect(Rect.fromLTWH(size.width - 48, 0, 48, 48), paint);
    canvas.drawRect(Rect.fromLTWH(size.width - 40, 8, 32, 32), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(size.width - 34, 14, 20, 20), paint);

    // 3. Bottom Left
    canvas.drawRect(Rect.fromLTWH(0, size.height - 48, 48, 48), paint);
    canvas.drawRect(Rect.fromLTWH(8, size.height - 40, 32, 32), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(14, size.height - 34, 20, 20), paint);

    // 4. Bottom Right alignment pattern (small square)
    canvas.drawRect(Rect.fromLTWH(size.width - 32, size.height - 32, 16, 16), paint);
    canvas.drawRect(Rect.fromLTWH(size.width - 28, size.height - 28, 8, 8), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(size.width - 26, size.height - 26, 4, 4), paint);

    // Draw some random mock QR pixel blocks
    final randomBlocks = [
      // Top section between detection patterns
      const Rect.fromLTWH(64, 8, 16, 8),
      const Rect.fromLTWH(88, 0, 8, 16),
      const Rect.fromLTWH(112, 16, 16, 16),
      // Left section
      const Rect.fromLTWH(8, 64, 16, 8),
      const Rect.fromLTWH(32, 88, 8, 16),
      const Rect.fromLTWH(16, 112, 16, 16),
      // Center section
      const Rect.fromLTWH(64, 64, 24, 24),
      const Rect.fromLTWH(100, 64, 16, 8),
      const Rect.fromLTWH(64, 100, 8, 16),
      const Rect.fromLTWH(80, 112, 32, 8),
      const Rect.fromLTWH(120, 80, 16, 16),
      // Right section
      Rect.fromLTWH(size.width - 64, 64, 16, 24),
      Rect.fromLTWH(size.width - 80, 100, 16, 8),
      // Bottom section
      const Rect.fromLTWH(64, 136, 24, 8),
      const Rect.fromLTWH(100, 144, 8, 24),
      const Rect.fromLTWH(120, 136, 16, 8),
    ];

    for (final rect in randomBlocks) {
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
