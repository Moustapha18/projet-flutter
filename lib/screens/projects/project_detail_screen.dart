import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_selector/file_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';
import '../../services/project_service.dart';
import '../../services/task_service.dart';
import '../../services/file_service.dart';
import '../../services/user_service.dart';
import '../tasks/add_task_screen.dart';
import '../tasks/task_detail_screen.dart';
import '../../services/pdf_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

class LocalPdfList extends StatefulWidget {
  @override
  _LocalPdfListState createState() => _LocalPdfListState();
}

class _LocalPdfListState extends State<LocalPdfList> {
  List<FileSystemEntity> pdfFiles = [];

  @override
  void initState() {
    super.initState();
    _loadLocalPDFs();
  }

  Future<void> _loadLocalPDFs() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync().where((f) => f.path.endsWith('.pdf')).toList();

    setState(() {
      pdfFiles = files;
    });
  }

  Future<void> _deleteFile(File file) async {
    await file.delete();
    _loadLocalPDFs();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("🗑 Fichier supprimé.")));
  }

  Future<void> _renameFile(File file) async {
    final newName = await _showRenameDialog(file.path.split('/').last);
    if (newName != null && newName.trim().isNotEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      final newPath = '${dir.path}/$newName.pdf';
      await file.rename(newPath);
      _loadLocalPDFs();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Fichier renommé.")));
    }
  }

  Future<String?> _showRenameDialog(String oldName) {
    final controller = TextEditingController(text: oldName.replaceAll('.pdf', ''));
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Renommer le fichier"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: "Nouveau nom"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Annuler")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text("Renommer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pdfFiles.isEmpty
        ? Center(child: Text("📂 Aucun fichier PDF trouvé."))
        : ListView.builder(
      itemCount: pdfFiles.length,
      itemBuilder: (context, index) {
        final file = pdfFiles[index] as File;
        final fileName = file.path.split('/').last;

        return ListTile(
          leading: Icon(Icons.picture_as_pdf, color: Colors.red),
          title: Text(fileName),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'ouvrir') {
                OpenFile.open(file.path);
              } else if (value == 'partager') {
                Share.shareXFiles([XFile(file.path)], text: "Voici un PDF 📎");
              } else if (value == 'renommer') {
                _renameFile(file);
              } else if (value == 'supprimer') {
                _deleteFile(file);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'ouvrir', child: Text('📖 Ouvrir')),
              PopupMenuItem(value: 'partager', child: Text('📤 Partager')),
              PopupMenuItem(value: 'renommer', child: Text('✏️ Renommer')),
              PopupMenuItem(value: 'supprimer', child: Text('🗑 Supprimer')),
            ],
          ),
        );
      },
    );
  }
}
class LocalFilesScreen extends StatefulWidget {
  @override
  _LocalFilesScreenState createState() => _LocalFilesScreenState();
}

class _LocalFilesScreenState extends State<LocalFilesScreen> {
  late Future<List<FileSystemEntity>> _filesFuture;

  @override
  void initState() {
    super.initState();
    _filesFuture = listFilesInDocumentsDirectory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("📁 Fichiers locaux")),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: _filesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text("Aucun fichier trouvé."));

          final files = snapshot.data!;

          return ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              final fileName = file.path
                  .split('/')
                  .last;

              return ListTile(
                leading: Icon(Icons.insert_drive_file),
                title: Text(fileName),
                subtitle: Text(file.path),
                onTap: () {
                  ElevatedButton(
                    onPressed: () async {
                      await generateAndSavePDF();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("📁 PDF généré et sauvegardé !")),
                      );
                    },
                    child: Text("📄 Générer un PDF"),
                  );

                  // Tu peux implémenter une ouverture ici
                },
              );
            },
          );
        },
      ),
    );
  }
  Future<void> generateAndSavePDF() async {
    final pdf = pw.Document();

    // Exemple simple de contenu PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text('📄 Ceci est un exemple de PDF généré'),
        ),
      ),
    );

    // Récupère le chemin du dossier local
    final outputDir = await getApplicationDocumentsDirectory();
    final outputFile = File('${outputDir.path}/rapport_${DateTime.now().millisecondsSinceEpoch}.pdf');

    // Sauvegarde du fichier PDF
    await outputFile.writeAsBytes(await pdf.save());

    print("✅ Fichier PDF sauvegardé à : ${outputFile.path}");
  }



  Future<List<FileSystemEntity>> listFilesInDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory
        .listSync(); // Récupère tous les fichiers et dossiers
    return files;
  }

}



class ProjectDetailScreen extends StatefulWidget {
  Project project;
  ProjectDetailScreen({required this.project});
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProjectService projectService = ProjectService();
  final TaskService taskService = TaskService();
  final FileService fileService = FileService();
  final UserService userService = UserService();

  String currentUserRole = "";
  String currentUserEmail = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await userService.getCurrentUserRole();
    final email = await projectService.getCurrentUserEmail();
    setState(() {
      currentUserRole = role ?? "";
      currentUserEmail = email ?? "";
    });
  }


  Future<void> _generateAndSharePdf() async {
    try {
      final tasks = await taskService.getTasksForProject(widget.project.id).first;
      final pdfData = await PdfService.generateProjectPdf(widget.project, tasks);

      final directory = await getTemporaryDirectory(); // Utilise un répertoire temporaire
      final path = "${directory.path}/${widget.project.title.replaceAll(' ', '_')}.pdf";
      final file = File(path);
      await file.writeAsBytes(pdfData);

      // 🔄 Partage le fichier
      await Share.shareXFiles([XFile(file.path)], text: "📄 Rapport PDF du projet ${widget.project.title}");

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erreur lors du partage du PDF : ${e.toString()}")),
      );
    }
  }


  Future<void> _changeStatus(String newStatus) async {
    if (currentUserRole == "membre") return;
    await projectService.updateProjectStatus(widget.project.id, newStatus);
  }
  Future<void> _exportPdf() async {
    try {
      final tasks = await taskService.getTasksForProject(widget.project.id).first;
      final pdfData = await PdfService.generateProjectPdf(widget.project, tasks);

      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/${widget.project.title.replaceAll(' ', '_')}.pdf";
      final file = File(path);

      await file.writeAsBytes(pdfData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("📄 PDF enregistré : ${file.path}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erreur export PDF : ${e.toString()}")),
      );
    }
  }
  Future<String> getApplicationDocumentsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }


  Future<void> _uploadFile() async {
    if (currentUserRole == "membre") return;

    final XFile? pickedFile = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(label: 'Documents & Images', extensions: ['jpg', 'jpeg', 'png', 'zip', 'doc', 'pdf']),
      ],
    );

    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❗ Aucun fichier sélectionné.")),
      );
      return;
    }

    try {
      final file = File(pickedFile.path);
      await fileService.uploadXFile(file as XFile, widget.project.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Fichier ajouté avec succès !")),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🚫 Erreur lors de l'ajout du fichier.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatDate = DateFormat('dd/MM/yyyy');
    final p = widget.project;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Aperçu"),
            Tab(text: "Tâches"),
            Tab(text: "Membres"),
            Tab(text: "Fichiers"),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            tooltip: "Exporter en PDF",
            onPressed: _exportPdf,
          ),
          IconButton(
            icon: Icon(Icons.share),
            tooltip: "Partager le PDF",
            onPressed: _generateAndSharePdf,
          ),
        ],

      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(formatDate, p),
          _buildTasksTab(),
          _buildMembersTab(),
          _buildFilesTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (currentUserRole == "membre") return null;

    if (_tabController.index == 1) {
      return FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(projectId: widget.project.id),
            ),
          );
          setState(() {});
        },
        child: Icon(Icons.add),
        tooltip: "Ajouter une tâche",
      );
    } else if (_tabController.index == 3) {
      return FloatingActionButton(
        onPressed: _uploadFile,
        child: Icon(Icons.attach_file),
        tooltip: "Joindre un fichier",
      );
    }
    return null;
  }

  Widget _buildOverviewTab(DateFormat formatDate, Project p) {
    return StreamBuilder<List<Task>>(
      stream: taskService.getTasksForProject(p.id),
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];
        final total = tasks.length;
        final done = tasks.where((t) => t.status == "Terminé").length;
        final inProgress = tasks.where((t) => t.status == "En cours").length;
        final toDo = tasks.where((t) => t.status == "À faire").length;
        final progress = total == 0 ? 0.0 : done / total;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  title: Text(p.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text("📌 Priorité : ${p.priority}", style: TextStyle(color: Colors.orange)),
                      Text("📝 ${p.description}"),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.date_range, size: 18),
                          SizedBox(width: 4),
                          Text("Début: ${formatDate.format(p.startDate)}"),
                          SizedBox(width: 12),
                          Text("Fin: ${formatDate.format(p.endDate)}"),
                        ],
                      ),
                      SizedBox(height: 8),
                      Chip(label: Text(p.status), backgroundColor: _getStatusColor(p.status)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Avancement du projet", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text("${(progress * 100).toStringAsFixed(0)}% terminé", style: TextStyle(fontSize: 18)),
                      SizedBox(height: 8),
                      LinearProgressIndicator(value: progress),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatusChip("À faire", toDo, Colors.orange),
                          _buildStatusChip("En cours", inProgress, Colors.blue),
                          _buildStatusChip("Terminé", done, Colors.green),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              if (currentUserRole != "membre") ...[
                SizedBox(height: 16),
                Text("Changer le statut du projet", style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: ["En attente", "En cours", "Terminé", "Annulé"]
                      .map((s) => ElevatedButton(
                    onPressed: () => _changeStatus(s),
                    child: Text(s),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getStatusColor(s),
                      foregroundColor: Colors.white,
                    ),
                  ))
                      .toList(),
                )
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Chip(
      label: Text("$label ($count)"),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }
  Widget _buildTasksTab() {
    return StreamBuilder<List<Task>>(
      stream: taskService.getTasksForProject(widget.project.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());

        final tasks = snapshot.data ?? [];
        if (tasks.isEmpty) return Center(child: Text("Aucune tâche pour ce projet."));

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final t = tasks[index];
            return Card(
              child: ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailScreen(task: t)));
                },
                title: Text(t.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("📌 Statut : ${t.status}"),
                    Text("🎯 Priorité : ${t.priority}"),
                    Text("📅 Échéance : ${DateFormat('dd/MM/yyyy').format(t.dueDate)}"),
                  ],
                ),
                trailing: (currentUserRole == "admin" || currentUserRole == "chef")
                    ? PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == "Modifier") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddTaskScreen(projectId: widget.project.id, existingTask: t),
                        ),
                      ).then((_) => setState(() {}));
                    } else if (value == "Supprimer") {
                      taskService.deleteTask(t.id);
                    } else {
                      _changeTaskStatus(t, value);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: "Modifier", child: Text("✏️ Modifier")),
                    PopupMenuItem(value: "Supprimer", child: Text("🗑 Supprimer")),
                    const PopupMenuDivider(),
                    ...["À faire", "En cours", "Terminé"]
                        .map((s) => PopupMenuItem(value: s, child: Text("🛠 $s"))),
                  ],
                )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMembersTab() {
    final p = widget.project;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final bool canAddMembers = p.createurId == currentUserId || p.chefProjetId == currentUserId;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: p.members.length,
            itemBuilder: (_, index) => ListTile(
              leading: Icon(Icons.person),
              title: Text(p.members[index]),
            ),
          ),
        ),
        if (canAddMembers)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _showAddMemberDialog,
              icon: Icon(Icons.person_add),
              label: Text("Ajouter un membre"),
            ),
          ),
      ],
    );
  }

  void _showAddMemberDialog() async {
    final usersSnapshot = await FirebaseFirestore.instance.collection("users").get();
    final allUsers = usersSnapshot.docs.map((doc) => doc.data()['email'] as String).toList();

    final selectedUsers = Set<String>.from(widget.project.members);

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text("Ajouter des collaborateurs"),
            content: Container(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: allUsers.map((email) {
                  final alreadySelected = selectedUsers.contains(email);
                  return CheckboxListTile(
                    title: Text(email),
                    value: alreadySelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedUsers.add(email);
                        } else {
                          selectedUsers.remove(email);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseFirestore.instance
                        .collection("projects")
                        .doc(widget.project.id)
                        .update({
                      "members": selectedUsers.toList(),
                    });
                    setState(() {
                      widget.project.members = selectedUsers.toList();
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("✅ Collaborateurs mis à jour.")),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("❌ Erreur: ${e.toString()}")),
                    );
                  }
                },
                child: Text("Valider"),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildFilesTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: fileService.getFiles(widget.project.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        final files = snapshot.data!;
        if (files.isEmpty) return Center(child: Text("📁 Aucun fichier disponible."));

        return ListView.builder(
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            return ListTile(
              leading: Icon(Icons.insert_drive_file),
              title: Text(file['name']),
              subtitle: Text("📤 Ajouté par : ${file['uploadedBy']}"),
              trailing: Icon(Icons.cloud_done, color: Colors.green),
              onTap: () => _showDownloadDialog(file['url']),
            );
          },
        );
      },
    );
  }

  void _showDownloadDialog(String url) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Lien de téléchargement"),
        content: SelectableText(url),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Fermer")),
        ],
      ),
    );
  }

  Future<void> _changeTaskStatus(Task task, String newStatus) async {
    await taskService.updateTaskStatus(task.id, newStatus);
    setState(() {});
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "En attente":
        return Colors.indigoAccent;
      case "En cours":
        return Colors.blue;
      case "Terminé":
        return Colors.green;
      case "Annulé":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

}






