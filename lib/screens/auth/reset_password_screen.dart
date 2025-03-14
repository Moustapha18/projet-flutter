import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Réinitialiser le mot de passe")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await authService.resetPassword(emailController.text);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Email envoyé !")));
              },
              child: Text("Envoyer un email de réinitialisation"),
            ),
          ],
        ),
      ),
    );
  }
}
