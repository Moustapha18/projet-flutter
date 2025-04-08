import 'dart:io';
import 'package:flutter/material.dart';
import 'package:projetmouhamadoumoustaphadioufl3gl/screens/projects/add_project_screen.dart';
import 'package:projetmouhamadoumoustaphadioufl3gl/screens/projects/project_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/project_model.dart';
import '../../services/project_service.dart';
import '../../services/user_service.dart';
import '../users/user_management_screen.dart';
import '../users/user_profile_screen.dart';

class KanbanScreen extends StatefulWidget {
  @override
  _KanbanScreenState createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> with SingleTickerProviderStateMixin {
  final ProjectService projectService = ProjectService();
  final UserService userService = UserService();
  final List<String> statuses = ["En attente", "En cours", "Terminé", "Annulé"];

  late TabController _tabController;
  String? _userRole;
  String? _name;
  String? _bio;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: statuses.length, vsync: this);
    _loadAllUserData();
  }

  Future<void> _loadAllUserData() async {
    await _loadUserRole();
    await _loadUserProfile();
  }

  Future<void> _loadUserRole() async {
    final role = await userService.getCurrentUserRole();
    setState(() {
      _userRole = role;
    });
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? 'Nom inconnu';
      _bio = prefs.getString('bio') ?? '';
      _avatarPath = prefs.getString('selected_avatar');
    });
  }

  bool get canCreateProject {
    return _userRole == "admin" || _userRole == "chef" || _userRole == "adminGlobal";
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_userRole == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage:
                    _avatarPath != null ? AssetImage(_avatarPath!) : null,
                    backgroundColor: Colors.white,
                    child: _avatarPath == null
                        ? Icon(Icons.person, size: 40, color: Colors.white)
                        : null,
                  ),
                  SizedBox(height: 10),
                  Text(
                    _name ?? 'Utilisateur',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  if (_bio != null && _bio!.isNotEmpty)
                    Text(
                      _bio!,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Accueil"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Mon Profil"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UserProfileScreen()),
                ).then((_) => _loadUserProfile()); // pour rafraîchir après modif
              },
            ),
            if (canCreateProject)
              ListTile(
                leading: Icon(Icons.add_box),
                title: Text("Créer un projet"),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddProjectScreen()),
                  );
                  setState(() {});
                },
              ),
            if (_userRole == "adminGlobal")
              ListTile(
                leading: Icon(Icons.admin_panel_settings),
                title: Text("Utilisateurs"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UserManagementScreen()),
                  );
                },
              ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Déconnexion"),
              onTap: () {
                // TODO: Implémenter la déconnexion
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("SunuProjet"),
        bottom: TabBar(
          controller: _tabController,
          tabs: statuses.map((s) => Tab(text: s)).toList(),
        ),
        actions: [
          if (canCreateProject)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddProjectScreen()),
                );
                setState(() {});
              },
            ),
        ],
      ),
      body: StreamBuilder<List<Project>>(
        stream: projectService.getProjectsByUserRole(_userRole ?? ""),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          final projects = snapshot.data ?? [];

          return TabBarView(
            controller: _tabController,
            children: statuses.map((status) {
              final filtered = projects.where((p) {
                final normalized = (p.status ?? "")
                    .toLowerCase()
                    .trim()
                    .replaceAll(RegExp(r"[^\w]"), "");
                final target = status.toLowerCase().replaceAll(RegExp(r"[^\w]"), "");
                return normalized == target;
              }).toList();

              return _buildKanbanColumn(status, filtered);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildKanbanColumn(String status, List<Project> projects) {
    if (projects.isEmpty) {
      return Center(child: Text("Aucun projet dans cette catégorie."));
    }

    return ListView(
      padding: EdgeInsets.all(12),
      children: projects.map(_buildProjectCard).toList(),
    );
  }

  Widget _buildProjectCard(Project project, {bool isDragging = false}) {
    return Card(
      color: isDragging ? Colors.blue[200] : Colors.white,
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(project.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.description),
            Text("📅 Du ${project.startDate.toLocal().toString().split(' ')[0]} "
                "au ${project.endDate.toLocal().toString().split(' ')[0]}"),
            Text("🎯 Priorité : ${project.priority}"),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectDetailScreen(project: project),
            ),
          );
        },
      ),
    );
  }
}
