import 'dart:io';

import 'package:complaint_app/utils/show_toast.dart';
import 'package:complaint_app/widgets/gold_btn.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:complaint_app/models/complaint.dart';

class CreateComplaintPage extends StatefulWidget {
  const CreateComplaintPage({super.key});

  @override
  State<CreateComplaintPage> createState() => _CreateComplaintPageState();
}

class _CreateComplaintPageState extends State<CreateComplaintPage> {
  final _formKey = GlobalKey<FormState>();

  final _typeController = TextEditingController();
  final _agencyController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<XFile?> _selectedImages = [];
  final List<FilePickerResult?> _selectedDocuments = [];

  @override
  void dispose() {
    _typeController.dispose();
    _agencyController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _pickDocuments() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        _selectedDocuments.add(result);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeDocument(int index) {
    setState(() {
      _selectedDocuments.removeAt(index);
    });
  }

  void _submitComplaint() {
    if (_formKey.currentState!.validate()) {
      final complaint = Complaint(
        type: _typeController.text.trim(),
        agency: _agencyController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        images: _selectedImages,
        docs: _selectedDocuments,
      );

      // Here you would typically save the complaint to your data source
      debugPrint('Complaint created: ${complaint.type}');

      // Show success message and navigate back
      showToast(
        context: context,
        title: "Complaint Created",
        msg: "Complaint Created Successfully",
      );

      Navigator.pop(context, complaint);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Complaint'),
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
                // Type Field
                TextFormField(
                  controller: _typeController,
                  decoration: const InputDecoration(
                    labelText: 'Complaint Type *',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.white),
                    hintText: 'e.g., Noise Complaint, Traffic Issue',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter complaint type';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Agency Field
                TextFormField(
                  controller: _agencyController,
                  decoration: const InputDecoration(
                    labelText: 'Agency *',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    hintText: 'e.g., City Hall, Traffic Department',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter agency';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Location Field
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location *',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    hintText: 'e.g., Downtown, Main Street',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    hintText: 'Describe your complaint in detail...',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Images Section
                _buildImagesSection(),

                const SizedBox(height: 16),

                // Documents Section
                _buildDocumentsSection(),

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: GoldButton(
                    label: "Create Complaint",
                    onTap: _submitComplaint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Images (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Add Images'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            if (_selectedImages.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_selectedImages.length, (index) {
                  final image = _selectedImages[index];
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(image!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -8,
                        right: -8,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Documents (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickDocuments,
              icon: const Icon(Icons.attach_file),
              label: const Text('Add Documents'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            if (_selectedDocuments.isNotEmpty)
              Column(
                children: List.generate(_selectedDocuments.length, (index) {
                  print("Selected Doc length is: ${_selectedDocuments.length}");
                  final doc = _selectedDocuments[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            doc!.names[0]!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),

                        IconButton(
                          onPressed: () => _removeDocument(index),
                          icon: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }
}
