import 'package:complaint_app/models/complaint_display.dart';
import 'package:flutter/material.dart';
import 'package:complaint_app/models/complaint.dart';
import 'package:complaint_app/pages/complaint_detail.dart';

class ListComplaintsPage extends StatefulWidget {
  const ListComplaintsPage({super.key});

  @override
  State<ListComplaintsPage> createState() => _ListComplaintsPageState();
}

class _ListComplaintsPageState extends State<ListComplaintsPage> {
  // Sample data - in real app, this would come from your data source
  List<ComplaintDisplay> complaints = [
    ComplaintDisplay(
      type: 'Noise Complaint',
      agency: 'City Hall',
      location: 'Downtown',
      description: 'Loud construction noise during night hours',
      status: ComplaintStatus.processing,
    ),
    ComplaintDisplay(
      type: 'Traffic Issue',
      agency: 'Traffic Department',
      location: 'Main Street',
      description: 'Traffic light not working properly',
      status: ComplaintStatus.requiresExtraInformation,
    ),
    ComplaintDisplay(
      type: 'Garbage Collection',
      agency: 'Waste Management',
      location: 'Suburb Area',
      description: 'Garbage not collected for 3 days',
      status: ComplaintStatus.newStatus,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          final complaint = complaints[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: _getStatusIcon(complaint.status),
              title: Text(
                complaint.type,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    complaint.location,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${_getStatusText(complaint.status)}',
                    style: TextStyle(
                      color: _getStatusColor(complaint.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ComplaintDetailsPage(complaint: complaint),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/create-complaint');
        },
        backgroundColor: Color(0xFFBFA46F),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Icon _getStatusIcon(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.newStatus:
        return const Icon(Icons.new_releases, color: Colors.blue);
      case ComplaintStatus.processing:
        return const Icon(Icons.hourglass_empty, color: Colors.orange);

      case ComplaintStatus.finished:
        return const Icon(Icons.check_circle, color: Colors.green);
      case ComplaintStatus.rejected:
        return const Icon(Icons.cancel, color: Colors.red);
      case ComplaintStatus.requiresExtraInformation:
        return const Icon(Icons.warning, color: Colors.yellow);
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
}
