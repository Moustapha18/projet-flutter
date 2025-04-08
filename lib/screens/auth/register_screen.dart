import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(FontAwesomeIcons.userPlus, size: 80, color: Colors.blue),
              SizedBox(height: 20),
              Text("Créer un compte", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("Inscrivez-vous pour commencer", style: TextStyle(fontSize: 16)),
              SizedBox(height: 30),

              _buildTextField(nameController, "Nom complet", Icons.person),
              SizedBox(height: 15),
              _buildTextField(emailController, "Adresse email", Icons.email),
              SizedBox(height: 15),
              _buildTextField(passwordController, "Mot de passe", Icons.lock, obscureText: true),
              SizedBox(height: 15),
              _buildTextField(confirmPasswordController, "Confirmer mot de passe", Icons.lock_outline, obscureText: true),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (passwordController.text != confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("❌ Les mots de passe ne correspondent pas")),
                    );
                    return;
                  }

                  await authService.registerWithEmail(
                    nameController.text,
                    emailController.text,
                    passwordController.text,
                  );
                },
                child: Text("S'inscrire", style: TextStyle(fontSize: 18)),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Retour à la connexion", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
