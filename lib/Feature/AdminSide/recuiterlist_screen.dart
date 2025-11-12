// screens/recruiters_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobapp/Feature/AdminSide/admin_recruiter_jobs_screen.dart';
import 'package:jobapp/Feature/AdminSide/provider/admininfo_provider.dart';
import 'package:jobapp/Feature/Recuiter/recuiter_model/recuiterinfo_model.dart';

class RecruitersListScreen extends ConsumerStatefulWidget {
  const RecruitersListScreen({super.key});
  @override
  ConsumerState<RecruitersListScreen> createState() =>
      _RecruitersListScreenState();
}

class _RecruitersListScreenState extends ConsumerState<RecruitersListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recruitersAsync = ref.watch(allRecruitersProvider);
    final colorScheme = Theme.of(context).colorScheme;
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Recruiters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search recruiters...',
              hintStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
              prefixIcon: Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              // Implement search functionality
            },
          ),
          SizedBox(height: 16),
          Expanded(
            child: recruitersAsync.when(
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 50, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load recruiters',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ],
                ),
              ),
              data: (recruiters) {
                if (recruiters.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 60,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No recruiters found',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: recruiters.length,
                  itemBuilder: (context, index) {
                    final recruiter = recruiters[index];
                    return _buildRecruiterCard(
                      recruiter,
                      colorScheme,
                      height,
                      width,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecruiterCard(
    RecruiterModel recruiter,
    ColorScheme colorScheme,
    double height,
    double width,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          backgroundImage: recruiter.photoUrl.isNotEmpty
              ? NetworkImage(recruiter.photoUrl)
              : null,
          child: recruiter.photoUrl.isEmpty
              ? Icon(Icons.person, color: colorScheme.onPrimaryContainer)
              : null,
        ),
        title: Text(
          recruiter.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recruiter.companyName,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            Text(
              recruiter.email,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
            Text(
              '${recruiter.designation} • ${recruiter.location}',
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: () {
          // Navigate to recruiter details screen
          _showRecruiterDetails(recruiter, context);
        },
      ),
    );
  }

  void _showRecruiterDetails(RecruiterModel recruiter, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminRecruiterJobsScreen(
          recruiterEmail: recruiter.email,
          recruiterName: recruiter.name,
        ),
      ),
    );
  }
}

// Recruiter Details Bottom Sheet
class RecruiterDetailsBottomSheet extends ConsumerWidget {
  final RecruiterModel recruiter;

  const RecruiterDetailsBottomSheet({super.key, required this.recruiter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Header with avatar and basic info
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage: recruiter.photoUrl.isNotEmpty
                    ? NetworkImage(recruiter.photoUrl)
                    : null,
                child: recruiter.photoUrl.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 40,
                        color: colorScheme.onPrimaryContainer,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recruiter.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      recruiter.designation,
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      recruiter.companyName,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Detailed Information
          _buildDetailRow(Icons.email, 'Email', recruiter.email, colorScheme),
          _buildDetailRow(
            Icons.phone,
            'Contact',
            recruiter.contact,
            colorScheme,
          ),
          _buildDetailRow(
            Icons.location_on,
            'Location',
            recruiter.location,
            colorScheme,
          ),
          _buildDetailRow(
            Icons.calendar_today,
            'Joined',
            '${recruiter.createdAt.day}/${recruiter.createdAt.month}/${recruiter.createdAt.year}',
            colorScheme,
          ),
          SizedBox(height: 24),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Implement edit functionality
                  },
                  child: Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Implement contact functionality
                  },
                  child: Text('Contact'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
