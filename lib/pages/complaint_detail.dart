import 'package:complaint_app/models/complaint_display.dart';
import 'package:flutter/material.dart';
import 'package:complaint_app/models/complaint.dart';
import 'package:complaint_app/pages/edit_complaint.dart';

class ComplaintDetailsPage extends StatelessWidget {
  final ComplaintDisplay complaint;

  const ComplaintDetailsPage({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Details'),
        foregroundColor: Colors.white,
        actions: [
          if (complaint.status == ComplaintStatus.requiresExtraInformation)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditComplaintPage(complaint: complaint),
                  ),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Complaint Type
              _buildDetailCard('Complaint Type', complaint.type),

              const SizedBox(height: 16),

              // Agency
              _buildDetailCard('Agency', complaint.agency),

              const SizedBox(height: 16),

              // Location
              _buildDetailCard('Location', complaint.location),

              const SizedBox(height: 16),

              // Description
              _buildDetailCard('Description', complaint.description),

              const SizedBox(height: 16),

              // Status
              _buildStatusCard(),

              const SizedBox(height: 16),

              // Extra Information (if available)
              if (complaint.extraInformation != null)
                _buildDetailCard(
                  'Additional Information',
                  complaint.extraInformation!,
                ),

              const SizedBox(height: 16),

              // Notes from Employee (if available)
              if (complaint.notesFromEmployee != null)
                _buildDetailCard(
                  'Notes from Employee',
                  complaint.notesFromEmployee!,
                ),

              const SizedBox(height: 16),

              // Images Section
              if (complaint.images.isNotEmpty) _buildImagesSection(),

              const SizedBox(height: 16),

              // Documents Section
              if (complaint.docs.isNotEmpty) _buildDocumentsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: _getStatusBackgroundColor(complaint.status),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _getStatusIconData(complaint.status),
              color: _getStatusColor(complaint.status),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _getStatusText(complaint.status),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(complaint.status),
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

  Widget _buildImagesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Images',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: complaint.images
                  .where((image) => image != null)
                  .map(
                    (image) => Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(image!, fit: BoxFit.cover),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Documents',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ...complaint.docs
                .where((doc) => doc != null)
                .map(
                  (doc) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.insert_drive_file, size: 16),
                          const SizedBox(width: 8),
                          Text(doc!, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIconData(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.newStatus:
        return Icons.new_releases;
      case ComplaintStatus.processing:
        return Icons.hourglass_empty;
      case ComplaintStatus.finished:
        return Icons.check_circle;
      case ComplaintStatus.rejected:
        return Icons.cancel;
      case ComplaintStatus.requiresExtraInformation:
        return Icons.warning;
    }
  }

  String _getStatusText(ComplaintStatus status) {
    return status.value
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Color _getStatusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.newStatus:
        return Colors.blue;
      case ComplaintStatus.processing:
        return Colors.orange;
      case ComplaintStatus.finished:
        return Colors.green;
      case ComplaintStatus.rejected:
        return Colors.red;
      case ComplaintStatus.requiresExtraInformation:
        return Colors.yellow;
    }
  }

  Color _getStatusBackgroundColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.newStatus:
        return Colors.blue.withValues(alpha: 0.1);
      case ComplaintStatus.processing:
        return Colors.orange.withValues(alpha: 0.1);
      case ComplaintStatus.finished:
        return Colors.green.withValues(alpha: 0.1);
      case ComplaintStatus.rejected:
        return Colors.red.withValues(alpha: 0.1);
      case ComplaintStatus.requiresExtraInformation:
        return Colors.yellow.withValues(alpha: 0.1);
    }
  }
}
