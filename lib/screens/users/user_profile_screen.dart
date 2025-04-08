import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  String? _selectedAvatar;

  final List<String> availableAvatars = [
    'assets/avatar.jpg',
    'assets/avatar1.jpg',
    'assets/avatar2.png',
    'assets/avatar3.jpg',
    'assets/avatar4.jpg',
    'assets/avatar5.png',
    'assets/avatar6.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    nameController.text = prefs.getString('name') ?? '';
    bioController.text = prefs.getString('bio') ?? '';
    setState(() {
      _selectedAvatar = prefs.getString('selected_avatar');
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', nameController.text);
    await prefs.setString('bio', bioController.text);
    if (_selectedAvatar != null) {
      await prefs.setString('selected_avatar', _selectedAvatar!);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Profil enregistré')),
    );
  }

  void _showAvatarSelectionDialog() async {
    final prefs = await SharedPreferences.getInstance();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Choisir un avatar"),
        content: Container(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: availableAvatars.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemBuilder: (context, index) {
              final avatarPath = availableAvatars[index];
              return GestureDetector(
                onTap: () async {
                  await prefs.setString('selected_avatar', avatarPath);
                  setState(() {
                    _selectedAvatar = avatarPath;
                  });
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Image.asset(avatarPath),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarWidget = _selectedAvatar != null
        ? CircleAvatar(
      radius: 50,
      backgroundImage: AssetImage(_selectedAvatar!),
    )
        : CircleAvatar(
      radius: 50,
      child: Icon(Icons.person, size: 50),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Mon Profil')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: Column(
                children: [
                  avatarWidget,
                  TextButton.icon(
                    onPressed: _showAvatarSelectionDialog,
                    icon: Icon(Icons.image),
                    label: Text("Changer l'avatar"),
                  ),
                ],
              ),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nom complet'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: bioController,
              decoration: InputDecoration(labelText: 'Bio'),
              maxLines: 2,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('💾 Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
