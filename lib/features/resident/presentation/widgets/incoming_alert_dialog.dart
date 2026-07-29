import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../guard/domain/entities/checkin_entity.dart';
import '../providers/resident_provider.dart';

class IncomingAlertDialog extends StatefulWidget {
  final CheckInEntity checkin;

  const IncomingAlertDialog({
    super.key,
    required this.checkin,
  });

  @override
  State<IncomingAlertDialog> createState() => _IncomingAlertDialogState();
}

class _IncomingAlertDialogState extends State<IncomingAlertDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final residentProvider = Provider.of<ResidentProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        elevation: 16,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.glassBorder : AppColors.lightSurfaceLight,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withAlpha(20),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulse Ring Accent
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.doorbell_rounded,
                        size: 40,
                        color: AppColors.accent,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              
              const Text(
                'Incoming Visitor Alert',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Outfit',
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 12),
              
              Text(
                'A visitor is waiting at the gate for your flat.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
              ),
              const SizedBox(height: 24),

              // Detail Section
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBg : AppColors.lightSurfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.glassBorder : AppColors.lightTextMuted.withAlpha(30),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      label: 'Visitor',
                      value: widget.checkin.visitorName,
                      icon: Icons.person_rounded,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      context,
                      label: 'Purpose',
                      value: widget.checkin.purpose,
                      icon: Icons.info_outline_rounded,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      context,
                      label: 'Gate',
                      value: widget.checkin.gateNumber,
                      icon: Icons.sensor_door_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        residentProvider.respondToAlert(widget.checkin.id, 'DENIED');
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error.withAlpha(20),
                        foregroundColor: AppColors.error,
                        elevation: 0,
                        side: const BorderSide(color: AppColors.error, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Deny Entry'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        residentProvider.respondToAlert(widget.checkin.id, 'APPROVED');
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Approve Entry'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}
