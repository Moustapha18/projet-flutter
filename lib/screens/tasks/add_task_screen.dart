import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';

class AddTaskScreen extends StatefulWidget {
  final String projectId;
  final Task? existingTask;

  AddTaskScreen({required this.projectId, this.existingTask});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime? deadline;
  String priority = "Moyenne";
  String status = "À faire";

  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      final t = widget.existingTask!;
      titleController.text = t.title;
      descriptionController.text = t.description;
      deadline = t.dueDate;
      priority = t.priority;
      status = t.status;
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: deadline ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        deadline = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Veuillez sélectionner une date d’échéance."),
      ));
      return;
    }

    final task = Task(
      id: widget.existingTask?.id ?? "",
      projectId: widget.projectId,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      dueDate: deadline!,
      priority: priority,
      status: status,
    );

    if (widget.existingTask == null) {
      await TaskService().addTask(task);
    } else {
      await TaskService().updateTask(task);
    }

    Navigator.pop(context);
  }

  Future<void> _deleteTask() async {
    if (widget.existingTask != null) {
      await TaskService().deleteTask(widget.existingTask!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTask != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Modifier la tâche" : "Ajouter une tâche")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Titre"),
                validator: (value) =>
                value!.isEmpty ? "Le titre est obligatoire." : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Description"),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text("📅 Échéance: "),
                  Spacer(),
                  Text(deadline != null
                      ? dateFormat.format(deadline!)
                      : "Non définie"),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: Text("Choisir"),
                  )
                ],
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: priority,
                decoration: InputDecoration(labelText: "Priorité"),
                items: ["Basse", "Moyenne", "Haute", "Urgente"]
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) => setState(() => priority = val!),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: status,
                decoration: InputDecoration(labelText: "Statut"),
                items: ["À faire", "En cours", "Terminé"]
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => status = val!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(isEditing ? "Mettre à jour" : "Ajouter la tâche"),
              ),
              if (isEditing)
                TextButton.icon(
                  onPressed: _deleteTask,
                  icon: Icon(Icons.delete, color: Colors.red),
                  label: Text("Supprimer", style: TextStyle(color: Colors.red)),
                )
            ],
          ),
        ),
      ),
    );
  }
}
