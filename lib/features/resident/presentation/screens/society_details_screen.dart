import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/resident_provider.dart';

class SocietyDetailsScreen extends StatefulWidget {
  const SocietyDetailsScreen({super.key});

  @override
  State<SocietyDetailsScreen> createState() => _SocietyDetailsScreenState();
}

class _SocietyDetailsScreenState extends State<SocietyDetailsScreen> {
  final Map<String, bool> _expandedNotices = {};

  void _showPaymentSheet(BuildContext context, String userId, String duesStr) {
    final remarksController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Autofill with current outstanding dues by default
    amountController.text = duesStr;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool isPaying = false;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 30,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(80),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Submit Payment Proof',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Transfer outstanding dues of ₹$duesStr to the society bank account, then submit your transaction details below.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    // Society Bank Account Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBg : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.glassBorder : Colors.grey[300]!,
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SOCIETY BANK ACCOUNT DETAILS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Bank Name:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text('HDFC Bank Ltd', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Account Name:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text('Homext Co-Op Society', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('A/C Number:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text('50100239485728', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('IFSC Code:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text('HDFC0000120', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount Paid (₹)',
                        prefixIcon: Icon(Icons.currency_rupee_rounded),
                        hintText: 'e.g. 2000',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the amount paid';
                        }
                        final paid = double.tryParse(value);
                        if (paid == null || paid <= 0) {
                          return 'Please enter a valid amount';
                        }
                        final totalDues = double.tryParse(duesStr) ?? 0.0;
                        if (paid > totalDues) {
                          return 'Amount paid cannot exceed outstanding dues (₹$duesStr)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: remarksController,
                      decoration: const InputDecoration(
                        labelText: 'Transaction Ref ID / UPI ID',
                        prefixIcon: Icon(Icons.receipt_long_rounded),
                        hintText: 'e.g. UPI Ref 382910, Bank Txn 1029',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter transaction reference or remarks';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    isPaying
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                setSheetState(() {
                                  isPaying = true;
                                });
                                final provider = Provider.of<ResidentProvider>(context, listen: false);
                                await provider.submitPaymentVerification(
                                  userId: userId,
                                  remarks: remarksController.text.trim(),
                                  amountPaid: amountController.text.trim(),
                                );
                                
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  _showSuccessDialog(context);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Submit Proof', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.secondary,
                  child: Icon(Icons.check_rounded, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  'Proof Submitted',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your payment reference details have been submitted. The society admin will verify and clear your dues shortly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(120, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Awesome'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final residentProvider = Provider.of<ResidentProvider>(context);
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final societyName = user.metadata['societyName'] ?? 'Society Portal';
    final notices = residentProvider.notices;

    final maintenancePaid = user.metadata['maintenancePaid'] == 'true';
    final monthlyMaintenance = double.tryParse(residentProvider.monthlyMaintenance) ?? 2500.0;
    final chargesList = user.metadata['charges'] as List? ?? [];
    
    final dues = double.tryParse(user.metadata['pendingDues']?.toString() ?? '0') ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          societyName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dues Card
            (() {
              final paymentStatus = user.metadata['paymentStatus'] ?? 'unpaid';
              final isPending = paymentStatus == 'pending_confirmation';
              
              final gradient = isPending
                  ? [Colors.orange.withAlpha(20), Colors.orange.withAlpha(40)]
                  : (dues > 0
                      ? [AppColors.error.withAlpha(20), AppColors.error.withAlpha(40)]
                      : [AppColors.secondary.withAlpha(20), AppColors.secondary.withAlpha(40)]);
              
              final borderColor = isPending
                  ? Colors.orange.withAlpha(60)
                  : (dues > 0 ? AppColors.error.withAlpha(60) : AppColors.secondary.withAlpha(60));

              final statusText = isPending
                  ? 'VERIFICATION PENDING'
                  : (dues > 0 ? 'DUES PENDING' : 'ALL CLEAR');

              final statusColor = isPending
                  ? Colors.orange
                  : (dues > 0 ? AppColors.error : AppColors.secondary);

              final statusIcon = isPending
                  ? Icons.hourglass_empty_rounded
                  : (dues > 0 ? Icons.warning_amber_rounded : Icons.verified_user_rounded);

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 12,
                          ),
                        ),
                        Icon(statusIcon, color: statusColor),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dues > 0 ? '₹${dues.toStringAsFixed(0)}' : 'No Outstanding Dues',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: dues > 0 ? (isPending ? Colors.orange : AppColors.error) : AppColors.secondary,
                      ),
                    ),
                     const SizedBox(height: 4),
                    if (isPending) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withAlpha(50)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.hourglass_empty_rounded, color: Colors.orange, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'Approval Pending: ₹${user.metadata['pendingPaymentAmount'] ?? '0'}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ref: ${user.metadata['paymentRemarks'] ?? ''}',
                        style: TextStyle(
                          color: isDark ? Colors.orange[200] : Colors.orange[800],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Maintenance Billing Period: Aug 2026',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                    if (dues > 0) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Outstanding Breakdown:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (!maintenancePaid)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Fixed Monthly Maintenance', style: TextStyle(fontSize: 14)),
                              Text('₹${monthlyMaintenance.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ...chargesList.map((charge) {
                        final title = charge['title'] ?? 'Custom Charge';
                        final amountStr = charge['amount'] ?? '0';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(title, style: const TextStyle(fontSize: 14)),
                              Text('₹$amountStr', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: isPending
                            ? null
                            : () => _showPaymentSheet(context, user.uid, dues.toStringAsFixed(0)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPending ? Colors.orange : AppColors.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(double.infinity, 48),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(isPending ? Icons.hourglass_bottom_rounded : Icons.payment_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              isPending ? 'Verification Pending' : 'Submit Payment Proof',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            })(),
            const SizedBox(height: 28),

            // Announcement Board Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notice Board',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                ),
                const Icon(Icons.campaign_rounded, color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 16),

            if (notices.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.glassBorder : AppColors.lightSurfaceLight),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.campaign_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Notice Board is empty',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Announcements posted by the society admin will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              )
            else ...[
              // Featured Latest Notice
              _buildFeaturedNotice(context, notices.first, isDark),
              const SizedBox(height: 24),

              if (notices.length > 1) ...[
                const Text(
                  'Older Announcements',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notices.length - 1,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final notice = notices[index + 1];
                    final isExpanded = _expandedNotices[notice.id] ?? false;
                    return Card(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _expandedNotices[notice.id] = !isExpanded;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      notice.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${notice.timestamp.day}/${notice.timestamp.month}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notice.content,
                                maxLines: isExpanded ? null : 2,
                                overflow: isExpanded ? null : TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'By: ${notice.postedBy}',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                                  ),
                                  Text(
                                    isExpanded ? 'Collapse' : 'Expand',
                                    style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedNotice(BuildContext context, dynamic notice, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withAlpha(60),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star_rounded, color: AppColors.primary, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'LATEST NOTICE',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${notice.timestamp.day}/${notice.timestamp.month}/${notice.timestamp.year}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            notice.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            notice.content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                'Posted by: ${notice.postedBy}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
