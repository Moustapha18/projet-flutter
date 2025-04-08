import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:projetmouhamadoumoustaphadioufl3gl/screens/auth/login_screen.dart';
import 'package:projetmouhamadoumoustaphadioufl3gl/screens/auth/register_screen.dart';
import 'package:projetmouhamadoumoustaphadioufl3gl/screens/auth/reset_password_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());

  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://fwmdnbnbhpinpjbjqgbe.supabase.co',  // à remplacer par ton URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3bWRuYm5iaHBpbnBqYmpxZ2JlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxMDQyNzQsImV4cCI6MjA1OTY4MDI3NH0.-3hNYrxZuHSxQ6YQznkcvKrWXdh_DAAiI6wod7ANce8', // ⬅️ à remplacer
  );
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/reset-password': (context) => ResetPasswordScreen(),
      },
    );
  }
}
