import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _repository = AuthRepositoryImpl();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeTab = 'All'; // 'All', 'RESIDENT', 'GUARD'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

    final societyId = user.metadata['societyId'] ?? '';
    final societyName = user.metadata['societyName'] ?? 'Your Society';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Portal',
              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit', fontSize: 20),
            ),
            Text(
              societyName,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<List<UserEntity>>(
        stream: _repository.streamSocietyMembers(societyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final members = snapshot.data ?? [];
          final residentsCount = members.where((m) => m.role == 'RESIDENT').length;
          final guardsCount = members.where((m) => m.role == 'GUARD').length;

          // Filter members based on active tab and search query
          final filteredMembers = members.where((m) {
            final matchesTab = _activeTab == 'All' || m.role == _activeTab;
            
            final query = _searchQuery.toLowerCase();
            final matchesSearch = m.name.toLowerCase().contains(query) ||
                (m.role == 'RESIDENT' && m.flatNumber.toLowerCase().contains(query)) ||
                (m.role == 'GUARD' && m.gateNumber.toLowerCase().contains(query));

            return matchesTab && matchesSearch;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Stats Cards Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total Residents',
                        count: residentsCount,
                        icon: Icons.home_rounded,
                        color: AppColors.primary,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total Guards',
                        count: guardsCount,
                        icon: Icons.security_rounded,
                        color: AppColors.secondary,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Search Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search members by name, flat, or gate...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 3. Tab Filter Buttons
                Row(
                  children: [
                    _buildTabButton('All', 'All Members', isDark),
                    const SizedBox(width: 8),
                    _buildTabButton('RESIDENT', 'Residents', isDark),
                    const SizedBox(width: 8),
                    _buildTabButton('GUARD', 'Guards', isDark),
                  ],
                ),
                const SizedBox(height: 16),

                // 4. Members List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Members (${filteredMembers.length})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 5. Members List View
                Expanded(
                  child: filteredMembers.isEmpty
                      ? _buildEmptyState(isDark)
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filteredMembers.length,
                          itemBuilder: (context, index) {
                            final member = filteredMembers[index];
                            return _buildMemberCard(member, isDark);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRegisterMemberDialog(context, user),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Member'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.glassBorder : Colors.grey[200]!,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withAlpha(20),
            radius: 20,
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabValue, String label, bool isDark) {
    final isSelected = _activeTab == tabValue;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTab = tabValue;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkSurface : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.glassBorder : Colors.grey[300]!),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(UserEntity member, bool isDark) {
    final isResident = member.role == 'RESIDENT';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.glassBorder : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isResident
                ? AppColors.primary.withAlpha(20)
                : AppColors.secondary.withAlpha(20),
            radius: 20,
            child: Icon(
              isResident ? Icons.home_rounded : Icons.security_rounded,
              color: isResident ? AppColors.primary : AppColors.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  isResident ? 'Resident • Flat ${member.flatNumber}' : 'Guard • ${member.gateNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isResident ? 'Resident' : 'Guard',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isResident ? AppColors.primaryLight : AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            Icon(
              Icons.group_off_rounded,
              size: 48,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'No society members found',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your filters or search query.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRegisterMemberDialog(BuildContext context, UserEntity admin) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final flatController = TextEditingController();
    final gateController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String selectedRole = 'RESIDENT';

    showDialog(
      context: context,
      builder: (context) {
        bool isRegistering = false;

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
                        'Register New Member',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pre-register a resident or guard to grant them access inside ${admin.metadata['societyName'] ?? 'society'}.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Resident')),
                              selected: selectedRole == 'RESIDENT',
                              onSelected: (selected) {
                                if (selected) {
                                  setDialogState(() {
                                    selectedRole = 'RESIDENT';
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Guard')),
                              selected: selectedRole == 'GUARD',
                              onSelected: (selected) {
                                if (selected) {
                                  setDialogState(() {
                                    selectedRole = 'GUARD';
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: selectedRole == 'RESIDENT' ? 'Resident Name' : 'Guard Name',
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          hintText: selectedRole == 'RESIDENT' ? 'e.g. Rahul Verma' : 'e.g. Guard Ramesh',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone_iphone_rounded),
                          hintText: '98765 43210',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter phone number';
                          }
                          final clean = value.replaceAll(RegExp(r'\s+'), '');
                          if (clean.length < 10) {
                            return 'Please enter a valid 10-digit phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      if (selectedRole == 'RESIDENT')
                        TextFormField(
                          controller: flatController,
                          decoration: const InputDecoration(
                            labelText: 'Flat / House Number',
                            prefixIcon: Icon(Icons.home_outlined),
                            hintText: 'e.g. B-104',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter flat number';
                            }
                            return null;
                          },
                        )
                      else
                        TextFormField(
                          controller: gateController,
                          decoration: const InputDecoration(
                            labelText: 'Gate Number',
                            prefixIcon: Icon(Icons.security_outlined),
                            hintText: 'e.g. Gate 1',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter gate number';
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 24),

                      isRegistering
                          ? const Center(child: CircularProgressIndicator())
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(100, 44),
                                  ),
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      setDialogState(() {
                                        isRegistering = true;
                                      });

                                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                      final success = await authProvider.preRegisterMember(
                                        name: nameController.text.trim(),
                                        phone: phoneController.text.trim(),
                                        role: selectedRole,
                                        flatNumber: selectedRole == 'RESIDENT' ? flatController.text.trim() : null,
                                        gateNumber: selectedRole == 'GUARD' ? gateController.text.trim() : null,
                                        societyId: admin.metadata['societyId'] ?? '',
                                        societyName: admin.metadata['societyName'] ?? '',
                                      );

                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              success
                                                  ? '${selectedRole == 'RESIDENT' ? 'Resident' : 'Guard'} registered successfully!'
                                                  : (authProvider.errorMessage ?? 'Registration failed'),
                                            ),
                                            backgroundColor: success ? Colors.green : AppColors.error,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text('Register'),
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
}
