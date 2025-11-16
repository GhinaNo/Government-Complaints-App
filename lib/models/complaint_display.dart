// Enum for complaint status
import 'package:uuid/uuid.dart';
import 'package:complaint_app/models/complaint.dart';

// Model class for Complaint
class ComplaintDisplay {
  ComplaintDisplay({
    String? uuid,
    required this.type,
    required this.agency,
    required this.location,
    required this.description,
    this.images = const [],
    this.docs = const [],
    this.status = ComplaintStatus.newStatus,
    this.notesFromEmployee,
    this.extraInformation,
  }) : uuid = uuid ?? const Uuid().v4();

  final String uuid;
  final String type;
  final String agency;
  final String location;
  final String description;
  final List<String?> images;
  final List<String?> docs;
  final ComplaintStatus status;
  final String? notesFromEmployee;

  final String? extraInformation;
}
