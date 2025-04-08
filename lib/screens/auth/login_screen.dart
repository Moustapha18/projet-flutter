import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth_service.dart';
import '../projects/kanban_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.userCircle, size: 80, color: Colors.blue),
              SizedBox(height: 20),
              Text("Bienvenue ", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Connectez-vous pour continuer", style: TextStyle(color: Colors.grey[700])),
              SizedBox(height: 30),
              _buildTextField(emailController, "Adresse Email", Icons.email),
              SizedBox(height: 16),
              _buildTextField(passwordController, "Mot de passe", Icons.lock, obscureText: true),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  User? user = await authService.signInWithEmail(
                      emailController.text.trim(), passwordController.text.trim());

                  if (user != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => KanbanScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Email ou mot de passe incorrect")),
                    );
                  }
                },
                child: Text("Se connecter", style: TextStyle(fontSize: 16)),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/reset-password'),
                child: Text("Mot de passe oublié ?"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Pas encore de compte ?"),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: Text("Créer un compte", style: TextStyle(color: Colors.blue)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}
