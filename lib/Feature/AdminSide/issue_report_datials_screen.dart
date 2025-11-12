// screens/issue_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobapp/Feature/AdminSide/model/admin_issuereport.dart';
import 'package:jobapp/Feature/JobSeeker/provider/jobaccess_provider.dart';

class IssueDetailScreen extends ConsumerStatefulWidget {
  final AdminIssuereport issue;

  const IssueDetailScreen({super.key, required this.issue});

  @override
  ConsumerState<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends ConsumerState<IssueDetailScreen> {
  final TextEditingController _responseController = TextEditingController();
  String _selectedStatus = 'pending';
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _statusOptions = [
    {'value': 'pending', 'label': 'Pending', 'color': Colors.orange},
    {'value': 'in_progress', 'label': 'In Progress', 'color': Colors.blue},
    {'value': 'resolved', 'label': 'Resolved', 'color': Colors.green},
  ];

  final List<Map<String, dynamic>> _quickResponses = [
    {
      'title': 'Thank you for reporting',
      'message': 'Thank you for bringing this to our attention. We are looking into it and will update you shortly.'
    },
    {
      'title': 'Issue Under Investigation',
      'message': 'We have received your report and our team is currently investigating the matter. We appreciate your patience.'
    },
    {
      'title': 'Resolution Update',
      'message': 'The issue has been resolved. Thank you for your patience and cooperation.'
    },
    {
      'title': 'Additional Information Needed',
      'message': 'Could you please provide more details about this issue to help us investigate further?'
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.issue.status;
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _updateIssueStatus() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = ref.read(jobRepositoryProvider);

      // Determine admin response - use provided text or default based on status
      String? adminResponse = _responseController.text.trim().isNotEmpty
          ? _responseController.text.trim()
          : _getDefaultResponseForStatus(_selectedStatus);

      // Determine user type and email based on available fields
      final userType = widget.issue.jobseekerEmail != null ? 'jobseeker' : 'recruiter';
      final userEmail = widget.issue.jobseekerEmail ?? widget.issue.recruiterEmail ?? '';

      await repository.updateIssueStatus(
        issueId: widget.issue.id,
        status: _selectedStatus,
        userEmail: userEmail,
        userType: userType,
        adminResponse: adminResponse,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Issue status updated to ${_selectedStatus.replaceAll('_', ' ')}'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        Navigator.pop(context);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update issue: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _getDefaultResponseForStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Thank you for your report. We have received it and will review it shortly.';
      case 'in_progress':
        return 'Your ${widget.issue.type} is now being investigated. We will update you with progress soon.';
      case 'resolved':
        return 'Your ${widget.issue.type} has been resolved. Thank you for your patience and cooperation.';
      default:
        return 'Your ${widget.issue.type} status has been updated.';
    }
  }

  void _useQuickResponse(Map<String, dynamic> response) {
    _responseController.text = response['message'];
    // Auto-set status to in_progress when using quick response
    if (_selectedStatus == 'pending') {
      setState(() {
        _selectedStatus = 'in_progress';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Details'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.issue.type == 'issue' 
                            ? Colors.orange.withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.issue.type.toUpperCase(),
                        style: TextStyle(
                          color: widget.issue.type == 'issue' ? Colors.orange : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(widget.issue.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.issue.status.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(widget.issue.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Issue Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.issue.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.issue.description,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: colorScheme.outline),
                    const SizedBox(height: 8),
                    _buildInfoRow('Submitted by', widget.issue.userName),
                    _buildInfoRow('Email', widget.issue.userEmail),
                    _buildInfoRow('Submitted on', _formatDate(widget.issue.createdAt)),
                    if (widget.issue.updatedAt != null)
                      _buildInfoRow('Last updated', _formatDate(widget.issue.updatedAt!)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Status Update Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Update Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _statusOptions.map((status) {
                        final isSelected = _selectedStatus == status['value'];
                        return ChoiceChip(
                          label: Text(status['label']),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus = status['value'];
                            });
                          },
                          selectedColor: status['color'],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : colorScheme.onSurface,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Admin Response Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Response',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your response will be visible to the user',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Quick Responses
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Responses:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _quickResponses.map((response) {
                            return FilterChip(
                              label: Text(response['title']),
                              onSelected: (selected) {
                                _useQuickResponse(response);
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    TextField(
                      controller: _responseController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Type your response here...',
                        border: OutlineInputBorder(),
                        labelText: 'Response Message',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
                // Existing Admin Response (if any)
            if (widget.issue.adminResponse != null) ...[
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Previous Response',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.issue.adminResponse!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Update Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _updateIssueStatus,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _getStatusColor(_selectedStatus),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        'UPDATE TO ${_selectedStatus.replaceAll('_', ' ').toUpperCase()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),
          ],
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
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}