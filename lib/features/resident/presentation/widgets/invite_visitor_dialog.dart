import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/resident_provider.dart';

class InviteVisitorDialog extends StatefulWidget {
  final String userId;
  final String flatNumber;
  final String hostName;

  const InviteVisitorDialog({
    super.key,
    required this.userId,
    required this.flatNumber,
    required this.hostName,
  });

  @override
  State<InviteVisitorDialog> createState() => _InviteVisitorDialogState();
}

class _InviteVisitorDialogState extends State<InviteVisitorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _purpose = 'Guest';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<ResidentProvider>(context, listen: false);
      final success = await provider.createInvite(
        userId: widget.userId,
        visitorName: _nameController.text.trim(),
        purpose: _purpose,
        inviteDate: _selectedDate,
        flatNumber: widget.flatNumber,
        hostName: widget.hostName,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visitor invitation code generated successfully!'),
            backgroundColor: AppColors.secondary,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to generate invite'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResidentProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 8,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Invite Visitor',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    )
                  ],
                ),
                const SizedBox(height: 20),

                // Visitor Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Visitor Name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                    hintText: 'Enter name (e.g. John Doe)',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter visitor name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Purpose Dropdown
                DropdownButtonFormField<String>(
                  value: _purpose,
                  decoration: const InputDecoration(
                    labelText: 'Purpose of Visit',
                    prefixIcon: Icon(Icons.info_outline_rounded),
                  ),
                  items: ['Guest', 'Delivery', 'Maintenance', 'Taxi', 'Other']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _purpose = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Date Picker field
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBg : AppColors.lightSurfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.glassBorder : AppColors.lightTextMuted.withAlpha(30),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date of Visit',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Save button
                provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Generate Invite Code'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
