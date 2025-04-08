import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project_model.dart';

class ProjectService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  final CollectionReference projectCollection =
  FirebaseFirestore.instance.collection('projects');

  /// 🔐 Récupère l'email de l'utilisateur connecté
  Future<String?> getCurrentUserEmail() async {
    final user = auth.currentUser;
    return user?.email;
  }

  /// 🔐 Récupère l'UID de l'utilisateur connecté
  Future<String?> getCurrentUserId() async {
    return auth.currentUser?.uid;
  }

  /// ➕ Création d’un nouveau projet
  Future<void> addProject(Project project) async {
    final user = auth.currentUser;
    if (user == null) return;

    final projectMap = project.toMap();

    projectMap['createurId'] = user.uid;       // ID du créateur
    projectMap['chefProjetId'] = user.uid;     // Le créateur est aussi chef au départ
    projectMap['createdBy'] = user.email;      // Email visible
    projectMap['members'] = [user.email];      // Auto-ajout comme membre

    await projectCollection.add(projectMap);
  }

  
  /// 🟢 Pour affichage générique (non filtré par rôle)
  Stream<List<Project>> getProjectsAsModel() {
    return projectCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Project.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// 🔁 Mise à jour du statut
  Future<void> updateProjectStatus(String projectId, String newStatus) async {
    await projectCollection.doc(projectId).update({'status': newStatus});
  }
  Stream<List<Project>> getProjectsByUserRole(String role) {
    final user = auth.currentUser;
    if (user == null) return Stream.value([]);

    if (role == "adminGlobal") {
      // Tous les projets
      return projectCollection.snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => Project.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
    } else {
      // Projets où l'utilisateur est createur, chef ou membre
      return projectCollection
          .where("members", arrayContains: user.email)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => Project.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((project) =>
      project.createurId == user.uid ||
          project.chefProjetId == user.uid ||
          project.members.contains(user.email))
          .toList());
    }
  }


  getProjects() {}
}
