import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_selector/file_selector.dart'; // 👈 nouveau

class FileService {
  final storage = FirebaseStorage.instance;
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  Future<void> uploadXFile(XFile xfile, String projectId) async {
    final user = auth.currentUser;
    if (user == null) return;

    final fileName = xfile.name;
    final fileBytes = await xfile.readAsBytes();
    final ref = storage.ref().child("project_files/$projectId/$fileName");

    await ref.putData(fileBytes); // 👈 on utilise les bytes, pas File
    final downloadUrl = await ref.getDownloadURL();

    await firestore
        .collection('projects')
        .doc(projectId)
        .collection('files')
        .add({
      'name': fileName,
      'url': downloadUrl,
      'uploadedBy': user.email,
      'uploadedAt': Timestamp.now(),
    });
  }

  Stream<List<Map<String, dynamic>>> getFiles(String projectId) {
    return firestore
        .collection('projects')
        .doc(projectId)
        .collection('files')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }
}
