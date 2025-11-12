import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobapp/Feature/JobSeeker/provider/jobseeker_provider.dart';
import 'package:jobapp/Feature/combomodel/jobupload_model.dart';

import '../provider/provider.dart';

class JobSeekerDashboard extends ConsumerStatefulWidget {
  const JobSeekerDashboard({super.key});

  @override
  ConsumerState<JobSeekerDashboard> createState() => _JobSeekerDashboardState();
}

class _JobSeekerDashboardState extends ConsumerState<JobSeekerDashboard> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    // Listen to search query changes and update controller
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobseekerProvider.notifier).loadJobseekerInfo();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Update provider only when text actually changes
    if (_searchController.text != ref.read(searchQueryProvider)) {
      ref.read(searchQueryProvider.notifier).state = _searchController.text;
    }
  }

  // Refresh method
  Future<void> _refreshData() async {
    // Invalidate providers to force refresh
    ref.invalidate(filteredJobsProvider);
    ref.invalidate(searchOnlyProvider);
    ref.invalidate(staticCategoriesProvider);
    // Wait a bit for the refresh to complete
    await Future.delayed(Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    // Safely access theme colors with fallbacks
    ColorScheme? colorScheme;
    try {
      colorScheme = Theme.of(context).colorScheme;
    } catch (e) {
      // Fallback to default colors if theme is not available
      colorScheme = ColorScheme.light();
    }
    final ref = this.ref;
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    // Decide which provider to use based on whether user is searching
    final jobsAsync = searchQuery.isEmpty
        ? ref.watch(
            filteredJobsProvider(selectedCategory),
          ) // Use category filter
        : ref.watch(searchOnlyProvider); // Use search results
    final jobseekerState = ref.watch(jobseekerProvider);
    final jobseekerInfo = jobseekerState.jobseekerInfo;

    // Get name and email
    final name = jobseekerInfo?.name ?? 'Master';
    // final email = jobseekerInfo?.email ?? '';
    // log('👤 Name: $name');
    // log('📧 Email: $email');
    return Scaffold(
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshData,
        color: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        strokeWidth: 2.0,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.surfaceContainerHighest,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.06, 0.4],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(height, width, colorScheme, name),
                  SizedBox(height: height * 0.02),
                  _buildSearchBar(height, width, colorScheme),
                  SizedBox(height: height * 0.02),
                  // Only show category section when not searching
                  if (searchQuery.isEmpty) ...[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        border: BoxBorder.all(
                          color: colorScheme.outline.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                        color: Colors.transparent,
                      ),
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            _buildCategorySection(
                              ref,
                              height,
                              width,
                              colorScheme,
                            ),
                            _buildJobMatchHeader(colorScheme),
                            _buildJobsList(
                              jobsAsync,
                              selectedCategory,
                              height,
                              width,
                              colorScheme,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // When searching, show search results in a simpler container
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                        color: Colors.transparent,
                      ),
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            _buildSearchHeader(
                              searchQuery,
                              context,
                              colorScheme,
                            ),
                            _buildJobsList(
                              jobsAsync,
                              "Search Results",
                              height,
                              width,
                              colorScheme,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader(
    String searchQuery,
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Search Results for "$searchQuery"',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, size: 20, color: colorScheme.onSurface),
          onPressed: () {
            // Clear search when close button is pressed
            _searchController.clear();
            ref.read(searchQueryProvider.notifier).state = '';
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(
    double height,
    double width,
    ColorScheme colorScheme,
    String name,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        left: width * 0.05,
        right: width * 0.02,
        top: height * 0.04,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $name',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: colorScheme.scrim,
            ),
          ),
          Text(
            'Let\'s get you hired for the job you deserve!',
            style: TextStyle(fontSize: 10, color: colorScheme.scrim),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(double height, double width, ColorScheme colorScheme) {
    return Consumer(
      builder: (context, ref, child) {
        final searchQuery = ref.watch(searchQueryProvider);
        // Sync controller with provider value (only if different)
        if (_searchController.text != searchQuery) {
          _searchController.text = searchQuery;
        }
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              // Search TextField
              Expanded(
                child: TextField(
                  controller: _searchController, // Use the same controller
                  decoration: InputDecoration(
                    hintText: 'Search by company, location, designation...',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 16,
                              color: colorScheme.onSurface,
                            ),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              // Filter Button
              SizedBox(width: width * 0.01),
              InkWell(
                onTap: () {
                  // _showFilterDialog(context, ref);//navigate to filter
                  context.push('/admin-dashboard');
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: height * 0.052,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: 20,
                        color: colorScheme.onSurface,
                      ),
                      SizedBox(width: width * 0.005),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategorySection(
    WidgetRef ref,
    double height,
    double width,
    ColorScheme colorScheme,
  ) {
    final staticCats = ref.watch(staticCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: height * 0.012),
        SizedBox(
          height: height * 0.04,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: staticCats.length + 1, // +1 for "All" category
            itemBuilder: (context, index) {
              final category = index == 0 ? 'All' : staticCats[index - 1];
              final isSelected = selectedCategory == category;
              return Padding(
                padding: EdgeInsets.only(right: width * 0.02),
                child: FilterChip(
                  label: Text(
                    category,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    ref.read(selectedCategoryProvider.notifier).state =
                        category;
                    log('Selected category: $category');
                  },
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  backgroundColor: colorScheme.surface,
                  selectedColor: colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildJobMatchHeader(ColorScheme colorScheme) {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Job match with you',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        Spacer(),
        TextButton(
          onPressed: () {
            context.push('/see-all-jobs');
          },
          child: Text(
            'See All',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Icon(Icons.arrow_drop_down, size: 18, color: colorScheme.onSurface),
      ],
    );
  }

  Widget _buildJobsList(
    AsyncValue<List<JobModel>> jobsAsync,
    String selectedCategory,
    double height,
    double width,
    ColorScheme colorScheme,
  ) {
    return jobsAsync.when(
      loading: () => SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              SizedBox(height: 10),
              Text(
                'Loading jobs...',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 40, color: colorScheme.error),
              SizedBox(height: 10),
              Text(
                'Failed to load jobs',
                style: TextStyle(fontSize: 12, color: colorScheme.error),
              ),
              SizedBox(height: 5),
              ElevatedButton(
                onPressed: _refreshData,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (jobs) {
        if (jobs.isEmpty) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 50,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(height: 10),
                  Text(
                    selectedCategory == 'All' ||
                            selectedCategory == 'Search Results'
                        ? 'No jobs available'
                        : 'No $selectedCategory jobs found',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _refreshData,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: Text('Refresh'),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return _buildJobCard(context, job, height, width, colorScheme);
          },
        );
      },
    );
  }

  // Rest of your methods remain the same (_buildJobCard, _buildJobTag, _calculateTimeAgo)
  Widget _buildJobCard(
    BuildContext context,
    JobModel job,
    double height,
    double width,
    ColorScheme colorScheme,
  ) {
    return InkWell(
      onTap: () {
        context.push('/job-details', extra: job);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.8),
            width: 01,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  width: 01,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: colorScheme.outline),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.shadow.withValues(
                                    alpha: 0.05,
                                  ),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(2.0),
                              child: ClipRRect(
                                clipBehavior: Clip.antiAlias,
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  job.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.broken_image,
                                      color: colorScheme.onSurfaceVariant,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: Text(
                                    job.designation,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 10),
                                SizedBox(
                                  width: width * 0.14,
                                  child: Text(
                                    '${job.ctc} ',
                                    style: TextStyle(
                                      fontSize: 09,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: width * 0.3,
                                  child: Text(
                                    '${job.companyName} ',
                                    style: TextStyle(
                                      fontSize: 09,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.location_pin,
                                  size: 15,
                                  color: colorScheme.outline.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                                SizedBox(
                                  width: width * 0.2,
                                  child: Text(
                                    ' ${job.location}',
                                    style: TextStyle(
                                      fontSize: 09,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildJobTag(job.noticePeriod, colorScheme),
                        _buildJobTag(job.jobType, colorScheme),
                        _buildJobTag(job.experience, colorScheme),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.alarm,
                    color: colorScheme.onSurfaceVariant,
                    size: 15,
                  ),
                  SizedBox(width: 5),
                  Text(
                    '${_calculateTimeAgo(job.createdAt)} ago',
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: 20),
                  // Icon(
                  //   Icons.person_2_outlined,
                  //   color: colorScheme.outline,
                  //   size: 15,
                  // ),
                  // SizedBox(width: 4),
                  // Text(
                  //   '8 application',
                  //   style: TextStyle(
                  //     color: colorScheme.outline,
                  //     fontSize: 8,
                  //     fontWeight: FontWeight.w400,
                  //   ),
                  // ),
                  Spacer(),
                  if (job.isUrgentHiring)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.05),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        'URGENT',
                        style: TextStyle(
                          color: colorScheme.error,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobTag(String text, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
      ),
    );
  }

  String _calculateTimeAgo(DateTime? postedDate) {
    if (postedDate == null) return 'ASAP';

    final difference = DateTime.now().difference(postedDate);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    }
  }
}
