import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobapp/Feature/AdminSide/jobseeekr_detail.screen.dart';
import 'package:jobapp/Feature/AdminSide/provider/admininfo_provider.dart';
import 'package:jobapp/Feature/AdminSide/provider/jobseekerprovider.dart'
    hide allJobSeekersProvider;
import 'package:jobapp/Feature/JobSeeker/modelclass/jobseeker_info.dart';

class CandidatelistScreen extends ConsumerStatefulWidget {
  const CandidatelistScreen({super.key});

  @override
  ConsumerState<CandidatelistScreen> createState() =>
      _CandidatelistScreenState();
}

class _CandidatelistScreenState extends ConsumerState<CandidatelistScreen> {
  @override
  Widget build(BuildContext context) {
    final jobseekersAsync = ref.watch(allJobSeekersProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: jobseekersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (jobseekers) {
          if (jobseekers.isEmpty) {
            return const Center(child: Text('No jobseekers found'));
          }
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: colorScheme.onPrimary,
                child: Text(
                  'Candidates Information',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // ListView wrapped with Expanded to take remaining space
              Expanded(
                child: ListView.builder(
                  itemCount: jobseekers.length,
                  itemBuilder: (context, index) {
                    final jobseeker = jobseekers[index];
                    return JobseekerListTile(
                      jobseeker: jobseeker,
                      onTap: () {
                        ref.read(selectedJobseekerProvider.notifier).state =
                            jobseeker;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CandidateDetailsScreen(
                              jobseekerEmail: jobseeker.email,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class JobseekerListTile extends ConsumerStatefulWidget {
  final JobseekerModel jobseeker;
  final VoidCallback onTap;

  const JobseekerListTile({
    super.key,
    required this.jobseeker,
    required this.onTap,
  });

  @override
  ConsumerState<JobseekerListTile> createState() => _JobseekerListTileState();
}

class _JobseekerListTileState extends ConsumerState<JobseekerListTile> {
  @override
  Widget build(BuildContext context) {
    // final statsAsync = ref.watch(
    //   jobseekerStatsProvider(widget.jobseeker.email),
    // );
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          child: Text(
            widget.jobseeker.name.isNotEmpty
                ? widget.jobseeker.name[0].toUpperCase()
                : 'J',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          widget.jobseeker.name.isNotEmpty ? widget.jobseeker.name : 'No Name',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.jobseeker.email),
            Text(
              '${widget.jobseeker.location} • ${widget.jobseeker.experience}',
            ),
            //     statsAsync.when(
            //       data: (stats) => Text(
            //         'Applications: ${stats.totalApplications} • '
            //         'Shortlisted: ${stats.shortlisted} • '
            //         'Rejected: ${stats.rejected}',
            //         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            //       ),
            //       loading: () => const Text(
            //         'Loading applications...',
            //         style: TextStyle(fontSize: 12),
            //       ),
            //       error: (error, stack) => const Text(
            //         'Error loading stats',
            //         style: TextStyle(fontSize: 12),
            //       ),
            //     ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: widget.onTap,
      ),
    );
  }
}
