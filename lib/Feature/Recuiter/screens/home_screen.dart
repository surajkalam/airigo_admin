import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jobapp/Feature/combomodel/application_model.dart';
import 'package:jobapp/core/util/appcolors.dart';
import '../provider/application_provider.dart';
import '../provider/provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int getTotalJobs(WidgetRef ref) {
    final totalJobsAsync = ref.watch(totalJobsCountProvider);
    return totalJobsAsync.maybeWhen(data: (value) => value, orElse: () => 0);
  }

  int getActiveJobsCount(WidgetRef ref) {
    final activeJobsAsync = ref.watch(activeJobsCountProvider);
    return activeJobsAsync.maybeWhen(
      data: (jobsList) => jobsList,
      orElse: () => 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalJobs = getTotalJobs(ref);
    final activeJobs = getActiveJobsCount(ref);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final totalApplicationsAsync = ref.watch(homeTotalApplicationsProvider);
    final shortlistedApplicationsAsync = ref.watch(
      homeShortlistedApplicationsProvider,
    );
    final pendingApplicationsAsync = ref.watch(homePendingApplicationsProvider);
    final recentApplicationsAsync = ref.watch(recentApplicationsProvider);
    if (totalApplicationsAsync.isLoading ||
        shortlistedApplicationsAsync.isLoading ||
        pendingApplicationsAsync.isLoading ||
        recentApplicationsAsync.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Recruiter Dashboard')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final totalApplications = totalApplicationsAsync.value ?? 0;
    final shortlistedApplications = shortlistedApplicationsAsync.value ?? 0;
    final pendingApplications = pendingApplicationsAsync.value ?? 0;
    final recentApplications = recentApplicationsAsync.value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Recruiter Dashboard'),
        backgroundColor: AppColors.faintbackblue,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
          decelerationRate: ScrollDecelerationRate.fast,
        ),
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(height, width),
              SizedBox(height: height * 0.03),
              // Quick Stats Section
              _buildQuickStatsSection(
                totalJobs,
                activeJobs,
                totalApplications,
                shortlistedApplications,
                height,
                width,
              ),
              SizedBox(height: height * 0.03),
              // Application Status Breakdown
              _buildApplicationBreakdown(
                totalApplications,
                shortlistedApplications,
                pendingApplications,
                height,
                width,
              ),
              SizedBox(height: height * 0.03),
              // Recent Applications
              _buildRecentApplicationsSection(
                recentApplications,
                height,
                width,
              ),
              SizedBox(height: height * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(double height, double width) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.faintbackblue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Iconsax.grid_edit, size: 40, color: Colors.blue),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                SizedBox(height: height * 0.005),
                Text(
                  'Manage your jobs and track applications efficiently',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection(
    int totalJobs,
    int activeJobs,
    int totalApplications,
    int shortlisted,
    double height,
    double width,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Overview',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: height * 0.015),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Jobs',
                totalJobs,
                Iconsax.briefcase,
                Colors.blue,
                height,
                width,
              ),
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: _buildStatCard(
                'Active Jobs',
                activeJobs,
                Iconsax.activity,
                Colors.green,
                height,
                width,
              ),
            ),
          ],
        ),
        SizedBox(height: height * 0.015),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Applications',
                totalApplications,
                Iconsax.document,
                Colors.orange,
                height,
                width,
              ),
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: _buildStatCard(
                'Shortlisted',
                shortlisted,
                Iconsax.profile_tick,
                Colors.purple,
                height,
                width,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApplicationBreakdown(
    int total,
    int shortlisted,
    int pending,
    double height,
    double width,
  ) {
    final rejected = total - shortlisted - pending;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Status',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: height * 0.01),
          if (total > 0) ...[
            _buildStatusRow(
              'Shortlisted',
              shortlisted,
              total,
              Colors.green,
              height,
            ),
            _buildStatusRow('Pending', pending, total, Colors.orange, height),
            _buildStatusRow('Rejected', rejected, total, Colors.red, height),
          ] else ...[
            Text(
              'No applications yet',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusRow(
    String status,
    int count,
    int total,
    Color color,
    double height,
  ) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.006),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              status,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '$count ($percentage%)',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentApplicationsSection(
    List<ApplicationModel> applications,
    double height,
    double width,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Applications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (applications.isNotEmpty)
              Text(
                '${applications.length} recent',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        SizedBox(height: height * 0.01),
        applications.isEmpty
            ? _buildEmptyApplicationsState(height)
            : SizedBox(
                height: height * 0.3,
                child: ListView.builder(
                  itemCount: applications.length,
                  itemBuilder: (context, index) {
                    final application = applications[index];
                    return _buildApplicationItem(application, height, width);
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildApplicationItem(
    ApplicationModel application,
    double height,
    double width,
  ) {
    return InkWell(
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getStatusColor(
              application.status,
            ).withValues(alpha: 0.1),
            child: Icon(
              _getStatusIcon(application.status),
              color: _getStatusColor(application.status),
              size: 20,
            ),
          ),
          title: Text(
            application.jobseekerName.isNotEmpty
                ? application.jobseekerName
                : 'Unknown Candidate',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            application.jobTitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(application.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              application.status.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: _getStatusColor(application.status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyApplicationsState(double height) {
    return SizedBox(
      height: height * 0.2,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            SizedBox(height: height * 0.009),
            Text(
              'No applications yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: height * 0.007),
            Text(
              'Applications will appear here when\ncandidates apply to your jobs',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    int value,
    IconData icon,
    Color color,
    double height,
    double width,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(width * 0.03),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: height * 0.01),
            Text(
              '$value',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: height * 0.005),
            Text(
              title,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'shortlisted':
        return Iconsax.profile_tick;
      case 'pending':
        return Iconsax.clock;
      case 'rejected':
        return Iconsax.close_circle;
      default:
        return Iconsax.document;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'shortlisted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
