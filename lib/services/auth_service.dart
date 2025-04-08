import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔐 Inscription avec nom complet, email et mot de passe
  Future<User?> registerWithEmail(String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      // 🔥 Ajouter utilisateur dans Firestore avec un rôle
      await _firestore.collection('users').doc(user!.uid).set({
        'name': name,
        'email': email,
        'role': 'membre', // 👈 rôle par défaut
      });

      return user;
    } catch (e) {
      print("Erreur d'inscription : $e");
      return null;
    }
  }

  // Connexion
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print("Erreur de connexion : $e");
      return null;
    }
  }
}
