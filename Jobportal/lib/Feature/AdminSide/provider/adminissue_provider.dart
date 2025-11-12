// providers/admin_issues_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:jobapp/Feature/AdminSide/model/admin_issuereport.dart';
import 'package:jobapp/Feature/JobSeeker/firebase_crud/jobaccess_repository.dart';


// All issues and reports provider
final allIssuesReportsProvider = StreamProvider<List<AdminIssuereport>>((ref) {
  final repository = ref.read(jobRepositoryProvider);
  return repository.getAllIssuesReports();
});



// Issues statistics provider
final issuesStatsProvider = Provider<Map<String, int>>((ref) {
  final issuesAsync = ref.watch(allIssuesReportsProvider);
  
  return issuesAsync.when(
    data: (issues) {
      return {
        'total': issues.length,
        'pending': issues.where((issue) => issue.status == 'pending').length,
        'in_progress': issues.where((issue) => issue.status == 'in_progress').length,
        'resolved': issues.where((issue) => issue.status == 'resolved').length,
        'issues': issues.where((issue) => issue.type == 'issue').length,
        'reports': issues.where((issue) => issue.type == 'report').length,
      };
    },
    loading: () => {
      'total': 0,
      'pending': 0,
      'in_progress': 0,
      'resolved': 0,
      'issues': 0,
      'reports': 0,
    },
    error: (error, stack) => {
      'total': 0,
      'pending': 0,
      'in_progress': 0,
      'resolved': 0,
      'issues': 0,
      'reports': 0,
    },
  );
});

// Selected issue provider
final selectedIssueProvider = StateProvider<AdminIssuereport?>((ref) => null);

final jobRepositoryProvider = Provider<JobRepository>((ref) => JobRepository());
