import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';
import 'add_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({required this.task});

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text("Détail de la tâche"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTaskScreen(
                    projectId: task.projectId,
                    existingTask: task,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("Supprimer la tâche"),
                  content: Text("Voulez-vous vraiment supprimer cette tâche ?"),
                  actions: [
                    TextButton(
                      child: Text("Annuler"),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    TextButton(
                      child: Text("Supprimer", style: TextStyle(color: Colors.red)),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await TaskService().deleteTask(task.id);
                Navigator.pop(context); // Revenir à l'écran précédent
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfo("Titre", task.title),
            _buildInfo("Description", task.description),
            _buildInfo("Statut", task.status),
            _buildInfo("Priorité", task.priority),
            _buildInfo("Échéance", dateFormat.format(task.dueDate)),
            if (task.assignedTo != null) _buildInfo("Assignée à", task.assignedTo!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label : ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
