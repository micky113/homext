import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../resident/data/repositories/resident_repository_impl.dart';
import '../../../resident/domain/entities/notice_entity.dart';

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
  int _currentIndex = 0; // 0 for Members, 1 for Notices

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
      body: _currentIndex == 0
          ? StreamBuilder<List<UserEntity>>(
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
                      _buildSocietyBillingCard(context, societyId, isDark),
                      const SizedBox(height: 16),
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
            )
          : _buildNoticeBoardView(societyId, user, isDark),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_currentIndex == 0) {
            _showRegisterMemberDialog(context, user);
          } else {
            _showPostNoticeDialog(context, user);
          }
        },
        icon: Icon(_currentIndex == 0 ? Icons.person_add_alt_1_rounded : Icons.campaign_rounded),
        label: Text(_currentIndex == 0 ? 'Add Member' : 'Add Notice'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Members',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_rounded),
            label: 'Notice Board',
          ),
        ],
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
          if (isResident) ...[
            const SizedBox(width: 8),
            if (member.metadata['paymentStatus'] == 'pending_confirmation')
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hourglass_empty_rounded, color: Colors.orange, size: 10),
                    SizedBox(width: 2),
                    Text(
                      'Verify',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              '₹${member.metadata['pendingDues'] ?? '0'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: (double.tryParse(member.metadata['pendingDues'] ?? '0') ?? 0.0) > 0 
                    ? AppColors.error 
                    : AppColors.secondary,
              ),
            ),
            InkWell(
              onTap: () => _showManageDuesDialog(context, member),
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.settings_suggest_rounded, color: AppColors.primary, size: 20),
              ),
            ),
          ] else ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBg : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Guard',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
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
  Widget _buildNoticeBoardView(String societyId, UserEntity admin, bool isDark) {
    return StreamBuilder<List<NoticeEntity>>(
      stream: ResidentRepositoryImpl().streamNotices(societyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final notices = snapshot.data ?? [];

        if (notices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No Announcements Yet',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap the "+" button below to post your first announcement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Announcements (${notices.length})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: notices.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final notice = notices[index];
                    return Card(
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${notice.timestamp.day}/${notice.timestamp.month}/${notice.timestamp.year}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notice.content,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.person_outline_rounded, size: 12, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  'By: ${notice.postedBy}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPostNoticeDialog(BuildContext context, UserEntity admin) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    bool isPosting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'New Announcement',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Outfit',
                                  ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Notice Title',
                            prefixIcon: Icon(Icons.title_rounded),
                            hintText: 'e.g. AGM Meeting Scheduled',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter notice title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: contentController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Notice Content',
                            prefixIcon: Icon(Icons.description_outlined),
                            hintText: 'Enter complete announcement content...',
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter notice content';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        isPosting
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
                                          isPosting = true;
                                        });

                                        try {
                                          await ResidentRepositoryImpl().postNotice(
                                            societyId: admin.metadata['societyId'] ?? '',
                                            title: titleController.text.trim(),
                                            content: contentController.text.trim(),
                                            postedBy: admin.name,
                                          );
                                          
                                          if (context.mounted) {
                                            Navigator.of(context).pop();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Announcement posted successfully!'),
                                                backgroundColor: AppColors.secondary,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            setDialogState(() {
                                              isPosting = false;
                                            });
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Failed to post notice: $e'),
                                                backgroundColor: AppColors.error,
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    child: const Text('Post Notice'),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSocietyBillingCard(BuildContext context, String societyId, bool isDark) {
    return StreamBuilder<String>(
      stream: ResidentRepositoryImpl().streamMonthlyMaintenance(societyId),
      builder: (context, snapshot) {
        final amount = snapshot.data ?? '2500';
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.glassBorder : Colors.grey[200]!,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Society Maintenance Billing',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => _showEditMaintenanceDialog(context, societyId, amount),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.edit_rounded, color: AppColors.primary, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fixed Monthly Maintenance:',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹$amount / month',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showGenerateBillsConfirmation(context, societyId, amount),
                      icon: const Icon(Icons.arrow_circle_up_rounded, size: 16),
                      label: const Text('Bill Residents', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showSpecialChargeDialog(context, societyId),
                      icon: const Icon(Icons.add_card_rounded, size: 16),
                      label: const Text('Special Charge', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditMaintenanceDialog(BuildContext context, String societyId, String currentAmount) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController(text: currentAmount);
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Edit Monthly Maintenance',
                style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit', fontSize: 18),
              ),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Maintenance Fee (₹)',
                    prefixIcon: Icon(Icons.currency_rupee_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter fee amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                isSaving
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            setDialogState(() {
                              isSaving = true;
                            });
                            try {
                              await ResidentRepositoryImpl().updateMonthlyMaintenance(
                                societyId: societyId,
                                amount: amountController.text.trim(),
                              );
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Monthly maintenance fee updated!'),
                                    backgroundColor: AppColors.secondary,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                setDialogState(() {
                                  isSaving = false;
                                });
                              }
                            }
                          }
                        },
                        child: const Text('Save'),
                      ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSpecialChargeDialog(BuildContext context, String societyId) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    bool isBilling = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Bill Special Charge',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              content: SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'This will bill a custom one-time charge to all residents in your society.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Charge Title / Purpose',
                            prefixIcon: Icon(Icons.receipt_long_rounded),
                            hintText: 'e.g. Development Fee',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter description / purpose';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Amount (₹)',
                            prefixIcon: Icon(Icons.currency_rupee_rounded),
                            hintText: 'e.g. 1000',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                if (isBilling)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else ...[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        setDialogState(() {
                          isBilling = true;
                        });
                        try {
                          final title = titleController.text.trim();
                          final amt = amountController.text.trim();
                          await ResidentRepositoryImpl().billSpecialCharge(
                            societyId: societyId,
                            title: title,
                            amount: amt,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Special charge "$title" of ₹$amt billed to all residents!'),
                                backgroundColor: AppColors.secondary,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            setDialogState(() {
                              isBilling = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to bill: $e'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Bill Residents'),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  void _showGenerateBillsConfirmation(BuildContext context, String societyId, String amount) {
    bool isGenerating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withAlpha(20),
                    child: const Icon(Icons.receipt_long_rounded, size: 20, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Bill Maintenance',
                      style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit', fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: Text(
                'Are you sure you want to generate monthly maintenance bills of ₹$amount for all residents in your society? This will add ₹$amount to their pending dues.',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              actions: [
                TextButton(
                  onPressed: isGenerating ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                isGenerating
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          setDialogState(() {
                            isGenerating = true;
                          });
                          try {
                            await ResidentRepositoryImpl().generateMonthlyBills(societyId: societyId);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Monthly maintenance bills generated for all residents!'),
                                  backgroundColor: AppColors.secondary,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              setDialogState(() {
                                isGenerating = false;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Generate Bills'),
                      ),
              ],
            );
          },
        );
      },
    );
  }

  void _showManageDuesDialog(BuildContext context, UserEntity member) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final totalDues = member.metadata['pendingDues'] ?? '0';
            final maintenancePaid = member.metadata['maintenancePaid'] == 'true';
            final chargesList = member.metadata['charges'] as List? ?? [];
            final paymentStatus = member.metadata['paymentStatus'] ?? 'unpaid';
            final remarks = member.metadata['paymentRemarks'] ?? '';

            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Manage Dues - Flat ${member.flatNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              content: SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          member.name,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (double.tryParse(totalDues) ?? 0.0) > 0
                                ? AppColors.error.withAlpha(15)
                                : AppColors.secondary.withAlpha(15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Outstanding Dues:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '₹$totalDues',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: (double.tryParse(totalDues) ?? 0.0) > 0
                                      ? AppColors.error
                                      : AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (paymentStatus == 'pending_confirmation') ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: Text(
                              'Verification Remarks: $remarks',
                              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.orange),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Text(
                          'Dues Breakdown:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Monthly Maintenance', style: TextStyle(fontSize: 14)),
                            Text(
                              maintenancePaid ? 'Paid' : 'Unpaid',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: maintenancePaid ? AppColors.secondary : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        if (chargesList.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          for (final charge in chargesList)
                            if (charge is Map)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(charge['title']?.toString() ?? 'Charge', style: const TextStyle(fontSize: 14)),
                                    Text('₹${charge['amount']?.toString() ?? '0'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                        ],
                        const Divider(height: 24),
                        const Text(
                          'Add New Charge:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Charge Title',
                            prefixIcon: Icon(Icons.receipt_long_rounded),
                            hintText: 'e.g. Late Parking Fee',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Amount (₹)',
                            prefixIcon: Icon(Icons.currency_rupee_rounded),
                            hintText: 'e.g. 500',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                if (isSaving)
                  const Center(child: CircularProgressIndicator())
                else if (paymentStatus == 'pending_confirmation') ...[
                  TextButton(
                    onPressed: () async {
                      setDialogState(() {
                        isSaving = true;
                      });
                      try {
                        await ResidentRepositoryImpl().rejectPayment(userId: member.uid);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Payment proof rejected.'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() {
                          isSaving = false;
                        });
                      }
                    },
                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                    child: const Text('Decline Proof'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      setDialogState(() {
                        isSaving = true;
                      });
                      try {
                        await ResidentRepositoryImpl().payDues(userId: member.uid);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Payment confirmed! Dues cleared.'),
                              backgroundColor: AppColors.secondary,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() {
                          isSaving = false;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Confirm Payment'),
                  ),
                ] else ...[
                  TextButton(
                    onPressed: () async {
                      setDialogState(() {
                        isSaving = true;
                      });
                      try {
                        await ResidentRepositoryImpl().payDues(userId: member.uid);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All dues waived successfully!'),
                              backgroundColor: AppColors.secondary,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() {
                          isSaving = false;
                        });
                      }
                    },
                    style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
                    child: const Text('Waive Dues'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        setDialogState(() {
                          isSaving = true;
                        });
                        try {
                          await ResidentRepositoryImpl().addCustomCharge(
                            userId: member.uid,
                            title: titleController.text.trim(),
                            amount: amountController.text.trim(),
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Custom charge added successfully!'),
                                backgroundColor: AppColors.secondary,
                              ),
                            );
                          }
                        } catch (e) {
                          setDialogState(() {
                            isSaving = false;
                          });
                        }
                      }
                    },
                    child: const Text('Add Charge'),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}
