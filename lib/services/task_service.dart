import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskService {
  final CollectionReference _collection = FirebaseFirestore.instance.collection("tasks");
  final CollectionReference _taskCollection =
  FirebaseFirestore.instance.collection('tasks');

  /// 🔁 Ajouter une tâche
  Future<void> addTask(Task task) async {
    await _taskCollection.add(task.toMap());
  }
// Ajoute dans ton TaskService


  Future<void> updateTask(Task task) async {
    await FirebaseFirestore.instance.collection('tasks').doc(task.id).update(task.toMap());
  }


  /// 📥 Récupérer les tâches liées à un projet donné
  Stream<List<Task>> getTasksByProject(String projectId) {
    return _taskCollection
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromMap(doc)).toList();
    });
  }

  /// 🔁 Mettre à jour le statut d'une tâche
  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    await _taskCollection.doc(taskId).update({'status': newStatus});
  }

  /// 🔁 Supprimer une tâche
  Future<void> deleteTask(String taskId) async {
    await _taskCollection.doc(taskId).delete();
  }

  Stream<List<Task>> getTasksForProject(String projectId) {
    return _collection
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromMap(doc)).toList();
    });
  }
}
