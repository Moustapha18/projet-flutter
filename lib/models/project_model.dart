import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final DateTime startDate;
  final DateTime endDate;
  late final List<String> members;

  final String? createurId;
  final String? chefProjetId;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.startDate,
    required this.endDate,
    required this.members,
    this.createurId,
    this.chefProjetId, required String createdBy,
  });

  factory Project.fromMap(Map<String, dynamic> data, String documentId) {
    return Project(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'En attente',
      priority: data['priority'] ?? 'Moyenne',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      members: List<String>.from(data['members'] ?? []),
      createurId: data['createurId'],
      chefProjetId: data['chefProjetId'], createdBy: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'startDate': startDate,
      'endDate': endDate,
      'members': members,
      'createurId': createurId,
      'chefProjetId': chefProjetId,
    };
  }
}
