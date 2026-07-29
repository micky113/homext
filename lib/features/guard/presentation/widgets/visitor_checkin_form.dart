import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/guard_provider.dart';

class VisitorCheckinForm extends StatefulWidget {
  final String guardId;
  final String gateNumber;

  const VisitorCheckinForm({
    super.key,
    required this.guardId,
    required this.gateNumber,
  });

  @override
  State<VisitorCheckinForm> createState() => _VisitorCheckinFormState();
}

class _VisitorCheckinFormState extends State<VisitorCheckinForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _flatController = TextEditingController();
  String _purpose = 'Delivery';

  @override
  void dispose() {
    _nameController.dispose();
    _flatController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<GuardProvider>(context, listen: false);
      final success = await provider.checkInVisitor(
        visitorName: _nameController.text.trim(),
        purpose: _purpose,
        flatNumber: _flatController.text.trim().toUpperCase(),
        gateNumber: widget.gateNumber,
        guardId: widget.guardId,
      );

      if (success && mounted) {
        _nameController.clear();
        _flatController.clear();
        setState(() {
          _purpose = 'Delivery';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visitor logged & Resident notification alert sent!'),
            backgroundColor: AppColors.secondary,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to log visitor check-in'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GuardProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: isDark ? 0 : 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Log New Entry',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
              ),
              const SizedBox(height: 16),

              // Visitor Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Visitor Name',
                  prefixIcon: Icon(Icons.badge_outlined),
                  hintText: 'e.g. Amazon Courier, Guest Name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter visitor name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Flat Selector / Input
              TextFormField(
                controller: _flatController,
                decoration: const InputDecoration(
                  labelText: 'Flat Number',
                  prefixIcon: Icon(Icons.apartment_rounded),
                  hintText: 'e.g. A-402, B-101',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter flat number';
                  }
                  if (!RegExp(r'^[A-Za-z]-[0-9]+$').hasMatch(value.trim())) {
                    return 'Format should be like A-402 or B-101';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Purpose Dropdown
              DropdownButtonFormField<String>(
                value: _purpose,
                decoration: const InputDecoration(
                  labelText: 'Purpose',
                  prefixIcon: Icon(Icons.assignment_ind_outlined),
                ),
                items: ['Delivery', 'Guest', 'Services', 'Cab', 'Other']
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
              const SizedBox(height: 20),

              // Submit
              provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Send Alert to Resident'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
