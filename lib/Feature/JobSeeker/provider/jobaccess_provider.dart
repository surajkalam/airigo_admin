//jobaccess  provider 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:jobapp/Feature/JobSeeker/firebase_crud/jobaccess_repository.dart';
import 'package:jobapp/Feature/combomodel/issue_report_model.dart';
import 'package:jobapp/Feature/combomodel/jobupload_model.dart';

final List<String> staticCategories = [
  'Hospitality',
  'Airline'
];
final searchQueryProvider = StateProvider<String>((ref) => '');
// Provider for selected job (to pass data between screens)
final selectedJobProvider = StateProvider<JobModel?>((ref) => null);

// Provider for selected category
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// Repository provider
final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository();
});

// Provider for all active jobs
final jobsProvider = StreamProvider<List<JobModel>>((ref) {
  final repository = ref.watch(jobRepositoryProvider);
  return repository.getActiveJobs();
});

// Provider for filtered jobs by category
final filteredJobsProvider = StreamProvider.family<List<JobModel>, String>((ref, category) {
  final repository = ref.watch(jobRepositoryProvider);
  if (category == 'All') {
    return repository.getActiveJobs();
  }
  return repository.getJobsByCategory(category);
});

// Provider for available categories (keep existing, don't remove)
final categoriesProvider = StreamProvider<List<String>>((ref) {
  final repository = ref.watch(jobRepositoryProvider);
  return repository.getAvailableCategories();
});

final staticCategoriesProvider = Provider<List<String>>((ref) {
  return staticCategories;
});

final searchResultsProvider = StreamProvider<List<JobModel>>((ref) {
  final searchQuery = ref.watch(searchQueryProvider);
  final jobRepository = ref.watch(jobRepositoryProvider);
  
  if (searchQuery.isEmpty) {
    // Return all active jobs when search is empty
    return jobRepository.getActiveJobs();
  }
  
  // Use the search method from repository
  return jobRepository.searchJobs(query: searchQuery);
});
// only search textfield
final searchOnlyProvider = StreamProvider<List<JobModel>>((ref) {
  final searchQuery = ref.watch(searchQueryProvider);
  final jobRepository = ref.watch(jobRepositoryProvider);
  
  // Only return results when there's a search query
  if (searchQuery.isEmpty) {
    return  Stream.value([]); // Empty when not searching
  }
  
  return jobRepository.searchJobs(query: searchQuery);
});

// Provider to fetch job details by jobId and recruiterEmail
final jobDetailsProvider = FutureProvider.autoDispose.family<JobModel?, JobDetailsParams>((ref, params) async {
  final repository = ref.read(jobRepositoryProvider);
  return await repository.getJobById(params.jobId, params.recruiterEmail);
});
 //report and issue 
final jobseekerIssuesProvider = StreamProvider.family<List<IssueReport>, String>((ref, jobseekerEmail) {
  final repository = ref.read(jobRepositoryProvider);
  return repository.getJobseekerIssues(jobseekerEmail);
});




// Parameters class for job details
class JobDetailsParams {
  final String jobId;
  final String recruiterEmail;

  JobDetailsParams({required this.jobId, required this.recruiterEmail});
}