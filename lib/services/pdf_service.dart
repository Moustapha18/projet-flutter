import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/project_model.dart';
import '../models/task_model.dart';

class PdfService {
  static Future<Uint8List> generateProjectPdf(Project project, List<Task> tasks) async {
    final pdf = pw.Document();
    final formatDate = DateFormat('dd/MM/yyyy');

    final progress = tasks.isEmpty
        ? 0.0
        : tasks.where((t) => t.status == "Terminé").length / tasks.length;

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text("Rapport du projet", style: pw.TextStyle(fontSize: 24))),
          pw.SizedBox(height: 10),
          pw.Text("📌 Titre : ${project.title}", style: pw.TextStyle(fontSize: 18)),
          pw.Text("📝 Description : ${project.description}"),
          pw.Text("🎯 Priorité : ${project.priority}"),
          pw.Text("📅 Du ${formatDate.format(project.startDate)} au ${formatDate.format(project.endDate)}"),
          pw.Text("🟢 Statut : ${project.status}"),
          pw.SizedBox(height: 10),
          pw.Text("👥 Collaborateurs :", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ...project.members.map((m) => pw.Bullet(text: m)),
          pw.SizedBox(height: 15),
          pw.Text("📊 Tâches (${tasks.length})", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
          ...tasks.map((task) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("• ${task.title}", style: pw.TextStyle(fontSize: 14)),
                pw.Text("  ↳ Statut : ${task.status} | Échéance : ${formatDate.format(task.dueDate)}"),
              ],
            ),
          )),
          pw.SizedBox(height: 10),
          pw.Text("✅ Progression : ${(progress * 100).toStringAsFixed(1)}%", style: pw.TextStyle(fontSize: 14)),
        ],
      ),
    );

    return pdf.save();
  }
}
