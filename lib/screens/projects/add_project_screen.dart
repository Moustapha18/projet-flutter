import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/project_model.dart';
import '../../services/project_service.dart';

class AddProjectScreen extends StatefulWidget {
  @override
  _AddProjectScreenState createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String priority = "Moyenne";
  String status = "En attente";
  final _formKey = GlobalKey<FormState>();
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  String? _errorMessage;

  Future<void> _selectDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        isStart ? startDate = picked : endDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      setState(() => _errorMessage = "Veuillez remplir tous les champs obligatoires.");
      return;
    }

    if (startDate != null && endDate != null && startDate!.isAfter(endDate!)) {
      setState(() => _errorMessage = "La date de début ne peut pas être après la date de fin.");
      return;
    }

    final email = await ProjectService().getCurrentUserEmail();
    if (email == null) {
      setState(() => _errorMessage = "Utilisateur non connecté.");
      return;
    }

    final project = Project(
      id: "",
      title: title,
      description: description,
      status: status,
      priority: priority,
      startDate: startDate ?? DateTime.now(),
      endDate: endDate ?? DateTime.now().add(Duration(days: 7)),
      members: [email],
      createdBy: email,
    );

    await ProjectService().addProject(project);
    Navigator.pop(context);
  }

  Widget _buildRadioPriority(String value) {
    return ListTile(
      title: Text(value),
      leading: Radio<String>(
        value: value,
        groupValue: priority,
        onChanged: (val) {
          setState(() => priority = val!);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Créer un projet")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_errorMessage != null)
                  Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: "Titre du projet", border: OutlineInputBorder()),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: "Description", border: OutlineInputBorder()),
                ),
                SizedBox(height: 16),
                Text("Dates du projet", style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text("Début: ${startDate != null ? dateFormat.format(startDate!) : "..."}"),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () => _selectDate(isStart: true),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text("Fin: ${endDate != null ? dateFormat.format(endDate!) : "..."}"),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () => _selectDate(isStart: false),
                      ),
                    ),
                  ],
                ),
                Divider(),
                Text("Priorité", style: TextStyle(fontWeight: FontWeight.bold)),
                _buildRadioPriority("Basse"),
                _buildRadioPriority("Moyenne"),
                _buildRadioPriority("Haute"),
                _buildRadioPriority("Urgente"),
                Divider(),
                Text("Statut du projet", style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: status,
                  items: ["En attente", "En cours", "Terminé", "Annulé"]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setState(() => status = val!),
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text("Créer le projet"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
