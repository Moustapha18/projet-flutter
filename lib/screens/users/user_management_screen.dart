import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/user_service.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserService userService = UserService();
  final List<String> roles = ['admin', 'chef', 'membre', 'adminGlobal'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des utilisateurs'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: userService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text('Aucun utilisateur trouvé.'));

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final email = user['email'] ?? 'Inconnu';
              final role = user['role'] ?? 'N/A';
              final isBlocked = user['isBlocked'] ?? false;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text(email),
                  subtitle: Text('Rôle : $role'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'Supprimer') {
                        await _confirmDelete(user['id']);
                      } else if (value == 'Bloquer') {
                        await userService.toggleUserBlock(user['id'], true);
                      } else if (value == 'Débloquer') {
                        await userService.toggleUserBlock(user['id'], false);
                      } else if (roles.contains(value)) {
                        await userService.updateUserRole(user['id'], value);
                      }
                      setState(() {});
                    },
                    itemBuilder: (_) => [
                      ...roles.map((r) => PopupMenuItem(
                        value: r,
                        child: Text("Changer rôle → $r"),
                      )),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: isBlocked ? 'Débloquer' : 'Bloquer',
                        child: Text(isBlocked ? '✅ Débloquer' : '🚫 Bloquer'),
                      ),
                      PopupMenuItem(
                        value: 'Supprimer',
                        child: Text('🗑 Supprimer'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirmation"),
        content: Text("Supprimer définitivement cet utilisateur ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Utilisateur supprimé.")),
      );
    }
  }
}


