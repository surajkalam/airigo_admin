// screens/admin_jobseeker_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobapp/Feature/AdminSide/model/application_model.dart';
import 'package:jobapp/Feature/AdminSide/provider/jobseekerprovider.dart';
import 'package:jobapp/Feature/JobSeeker/modelclass/jobseeker_info.dart';

class CandidateDetailsScreen extends ConsumerWidget {
  final String jobseekerEmail;

  const CandidateDetailsScreen({
    super.key,
    required this.jobseekerEmail,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailedInfoAsync = ref.watch(detailedJobseekerInfoProvider(jobseekerEmail));
    return Scaffold(
      appBar: AppBar(
        title:  Text('Jobseeker Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: detailedInfoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
        data: (detailedInfo) {
          if (detailedInfo == null) {
            return const Center(
              child: Text('Jobseeker not found'),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Info Card
                _buildBasicInfoCard(context, detailedInfo.jobseeker),
                const SizedBox(height: 16),
                
                // Application Stats Card
                _buildStatsCard(context, detailedInfo.stats),
                const SizedBox(height: 16),
                
                // Applications List
                _buildApplicationsList(context, detailedInfo.applications),
              ],
            ),
          );
        },
      ),
    );
  }
  Widget _buildBasicInfoCard(BuildContext context, JobseekerModel jobseeker) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Name', jobseeker.name),
            _buildInfoRow('Email', jobseeker.email),
            _buildInfoRow('Contact', jobseeker.contact),
            _buildInfoRow('Location', jobseeker.location),
            _buildInfoRow('Qualification', jobseeker.qualification),
            _buildInfoRow('Job Designation', jobseeker.jobDesignation),
            _buildInfoRow('Experience', jobseeker.experience),
            _buildInfoRow('Date of Birth', '${jobseeker.dateOfBirth} (Age: ${jobseeker.age})'),
            if (jobseeker.resumeUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  // Open resume URL
                },
                icon: const Icon(Icons.description),
                label: const Text('View Resume'),
              ),
            ],
          ],
        ),
      ),
    );
  }
  Widget _buildStatsCard(BuildContext context, JobseekerApplicationStats stats) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Application Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatItem('Total', stats.totalApplications.toString(), Colors.blue),
                _buildStatItem('Pending', stats.pending.toString(), Colors.orange),
                _buildStatItem('Shortlisted', stats.shortlisted.toString(), Colors.green),
                _buildStatItem('Rejected', stats.rejected.toString(), Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationsList(BuildContext context, List<JobApplication> applications) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Applications (${applications.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...applications.map((application) => _buildApplicationTile(context, application)),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationTile(BuildContext context, JobApplication application) {
    Color statusColor = Colors.orange;
    if (application.status == 'shortlisted') statusColor = Colors.green;
    if (application.status == 'rejected') statusColor = Colors.red;
    if (application.status == 'accepted') statusColor = Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[50],
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 8,
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          application.jobTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recruiter: ${application.recruiterEmail}'),
            Text('Applied: ${_formatDate(application.appliedDate)}'),
            if (application.jobDetails != null) ...[
              Text('Company: ${application.jobDetails!.companyName}'),
              Text('Salary: ${application.jobDetails!.ctc}'),
            ],
          ],
        ),
        trailing: Chip(
          label: Text(
            application.status.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: statusColor.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? 'Not provided' : value),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}