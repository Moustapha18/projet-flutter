import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';

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
      backgroundColor: Colors.blue[50],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.projectDiagram, size: 80, color: Colors.blue),
                SizedBox(height: 20),
                Text("Bienvenue !", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("Connectez-vous pour gérer vos projets", style: TextStyle(fontSize: 16)),
                SizedBox(height: 30),
                _buildTextField(emailController, "Email", Icons.email),
                SizedBox(height: 15),
                _buildTextField(passwordController, "Mot de passe", Icons.lock, obscureText: true),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await authService.signInWithEmail(emailController.text, passwordController.text);
                  },
                  child: Text("Se connecter", style: TextStyle(fontSize: 18)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                  },
                  child: Text("Créer un compte", style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
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
      ),
    );
  }
}
