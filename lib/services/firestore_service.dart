import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔍 Fonction pour récupérer les projets où l'utilisateur est membre
  Stream<List<Map<String, dynamic>>> getProjects() {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) {
      print("⚠️ Aucun utilisateur connecté !");
      return Stream.value([]);
    }

    print(" Recherche des projets où $userEmail est membre...");

    return FirebaseFirestore.instance
        .collection('projects')
        .where("members", arrayContains: userEmail)
        .snapshots()
        .map((snapshot) {
      print("📢 Nombre de projets trouvés : ${snapshot.docs.length}");

      for (var doc in snapshot.docs) {
        print("📌 Projet récupéré : ${doc.id}");
        print("   - Title : ${doc.data()["title"]}");
        print("   - Members : ${doc.data()["members"]}");
      }

      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // 📌 Fonction pour ajouter un projet
  Future<void> addProject(String title, String description, List<String>? members) async {
    try {
      String? userEmail = FirebaseAuth.instance.currentUser?.email;
      if (userEmail == null) {
        print("⚠️ Aucun utilisateur connecté !");
        return;
      }

      // 🛠 Assurer que `members` n'est jamais null
      if (members == null) {
        members = [];
      }

      // 🔹 Ajouter le créateur s'il n'est pas déjà dans la liste
      if (!members.contains(userEmail)) {
        members.add(userEmail);
      }

      print("📤 Envoi du projet à Firestore...");
      print("📌 Données envoyées :");
      print("   - Title : $title");
      print("   - Description : $description");
      print("   - Members : $members");

      await FirebaseFirestore.instance.collection('projects').add({
        "title": title,
        "description": description,
        "status": "En attente",
        "priority": "Moyenne",
        "startDate": Timestamp.now(),
        "endDate": Timestamp.now(),
        "members": FieldValue.arrayUnion(members), // 🔥 `arrayUnion` pour éviter les doublons
      });

      print("✅ Projet ajouté avec succès !");
    } catch (e) {
      print("❌ Erreur lors de l'ajout du projet : $e");
    }
  }


}



