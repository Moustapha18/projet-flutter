import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  final String projectId;

  TaskListScreen({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tâches du projet")),
      body: StreamBuilder<List<Task>>(
        stream: TaskService().getTasksByProject(projectId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final tasks = snapshot.data!;
          if (tasks.isEmpty) {
            return Center(child: Text("Aucune tâche trouvée pour ce projet."));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                child: ListTile(
                  title: Text(task.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📌 Priorité : ${task.priority}"),
                      Text("📅 Échéance : ${task.dueDate.toLocal().toString().split(' ')[0]}"),
                      Text("✅ Statut : ${task.status}"),
                    ],
                  ),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Tu pourras ajouter un détail plus tard ici
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(projectId: projectId),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: "Ajouter une tâche",
      ),
    );
  }
}
