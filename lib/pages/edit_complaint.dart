import 'package:complaint_app/models/complaint.dart';
import 'package:complaint_app/models/complaint_display.dart';
import 'package:flutter/material.dart';

class EditComplaintPage extends StatefulWidget {
  final ComplaintDisplay complaint;

  const EditComplaintPage({super.key, required this.complaint});

  @override
  State<EditComplaintPage> createState() => _EditComplaintPageState();
}

class _EditComplaintPageState extends State<EditComplaintPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _extraInformationController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing complaint data
    _extraInformationController = TextEditingController(
      text: widget.complaint.extraInformation ?? '',
    );
  }

  @override
  void dispose() {
    _extraInformationController.dispose();
    super.dispose();
  }

  void _updateComplaint() {
    if (_formKey.currentState!.validate()) {
      final updatedComplaint = ComplaintDisplay(
        uuid: widget.complaint.uuid,
        type: widget.complaint.type,
        agency: widget.complaint.agency,
        location: widget.complaint.location,
        description: widget.complaint.description,
        status: ComplaintStatus.requiresExtraInformation,
        extraInformation: _extraInformationController.text.trim().isNotEmpty
            ? _extraInformationController.text.trim()
            : null,
      );

      // Here you would typically update the complaint in your data source
      debugPrint('Complaint updated: ${updatedComplaint.type}');

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complaint updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, updatedComplaint);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Complaint'),

        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Info (read-only)
                Card(
                  color: Colors.yellow[100],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Current Status: ${_getStatusText(widget.complaint.status)}\n'
                            'You can only edit complaints with "Requires Extra Information" status.',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Extra Information Field (only for edit)
                TextFormField(
                  controller: _extraInformationController,
                  decoration: const InputDecoration(
                    labelText: 'Additional Information',
                    border: OutlineInputBorder(),
                    hintText: 'Provide any additional information...',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),

                // Update Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _updateComplaint,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Update Complaint',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusText(ComplaintStatus status) {
    return status.value
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
