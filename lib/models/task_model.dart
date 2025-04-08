import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String id;
  String title;
  String description;
  String status;
  String priority;
  DateTime dueDate;
  String projectId;
  String? assignedTo;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.projectId,
    this.assignedTo,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'dueDate': Timestamp.fromDate(dueDate),
      'projectId': projectId,
      'assignedTo': assignedTo,
    };
  }

  factory Task.fromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'En attente',
      priority: data['priority'] ?? 'Moyenne',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      projectId: data['projectId'],
      assignedTo: data['assignedTo'],
    );
  }
}
