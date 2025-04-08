// TODO Implement this library.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔐 Récupère le rôle de l'utilisateur connecté (admin, chef, membre)
  Future<String?> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['role'];
    } catch (e) {
      print("Erreur récupération rôle utilisateur: $e");
      return null;
    }
  }

  /// 📧 Récupère l'adresse email de l'utilisateur connecté
  Future<String?> getCurrentUserEmail() async {
    return _auth.currentUser?.email;
  }

  /// 🔁 Optionnel : récupère tout le profil utilisateur
  Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data();
    } catch (e) {
      print("Erreur récupération données utilisateur: $e");
      return null;
    }
  }
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'email': data['email'] is String ? data['email'] : (data['email'] as List).join(', '),
          'role': data['role'] ?? 'N/A',
          'isBlocked': data['isBlocked'] ?? false,
        };
      }).toList();
    });
  }


  Future<void> updateUserRole(String userId, String newRole) async {
    await _firestore.collection('users').doc(userId).update({'role': newRole});
  }

  Future<void> toggleUserBlock(String userId, bool block) async {
    await _firestore.collection('users').doc(userId).update({'isBlocked': block});
  }
}
