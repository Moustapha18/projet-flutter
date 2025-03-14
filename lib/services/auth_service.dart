import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Inscription
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.sendEmailVerification(); // Vérification d'email
      await FirebaseFirestore.instance.collection("users").doc(userCredential.user!.uid).set({
        "email": email,
        "role": "membre" // Par défaut, tout utilisateur est un membre
      });

      return userCredential.user;
    } catch (e) {
      print("Erreur d'inscription : $e");
      return null;
    }
  }

  // Connexion
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Erreur de connexion : $e");
      return null;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Récupération de mot de passe
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Vérifier si l’utilisateur est connecté
  Stream<User?> get user => _auth.authStateChanges();
}

Future<String?> getUserRole(String uid) async {
  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
  return userDoc["role"];
}

