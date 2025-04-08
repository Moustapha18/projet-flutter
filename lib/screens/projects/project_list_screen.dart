import 'package:flutter/material.dart';
import 'package:projetmouhamadoumoustaphadioufl3gl/screens/projects/project_detail_screen.dart';
import '../../models/project_model.dart';
import '../../services/project_service.dart';
import '../tasks/task_list_screen.dart';
import 'add_project_screen.dart';

class ProjectListScreen extends StatelessWidget {
  final ProjectService projectService = ProjectService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Projets")),
      body: StreamBuilder<List<Project>>(
        stream: projectService.getProjects(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          List<Project> projects = snapshot.data!;
          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              Project project = projects[index];
              return Card(
                child: ListTile(
                  title: Text(project.title),
                  subtitle: Text(project.description),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'détail') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProjectDetailScreen(project: project),
                          ),
                        );
                      } else if (value == 'tâches') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskListScreen(projectId: project.id),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'détail',
                        child: Text('Voir détail'),
                      ),
                      PopupMenuItem(
                        value: 'tâches',
                        child: Text('Voir tâches'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProjectScreen()),
          );
        },
      ),
    );
  }
}
