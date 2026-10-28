import 'package:flutter/widgets.dart';

import '../data/sample_data.dart';
import '../models/analysis.dart';
import '../models/patient.dart';
import '../models/risk.dart';

/// État de l'application : patients et analyses, en mémoire.
class Clinic extends ChangeNotifier {
  final List<Patient> patients = [...samplePatients];
  final List<Analysis> analyses = sampleAnalyses()..sort((a, b) => b.date.compareTo(a.date));

  void addPatient(Patient patient) {
    patients.insert(0, patient);
    notifyListeners();
  }

  void addAnalysis(Analysis analysis) {
    analyses.insert(0, analysis);
    notifyListeners();
  }

  List<Analysis> analysesOf(Patient patient) =>
      analyses.where((a) => a.patient.id == patient.id).toList();

  Analysis? latestOf(Patient patient) {
    for (final a in analyses) {
      if (a.patient.id == patient.id) return a;
    }
    return null;
  }

  int get highRiskCount =>
      analyses.where((a) => a.result.level == RiskLevel.high).length;
}

class ClinicScope extends InheritedNotifier<Clinic> {
  const ClinicScope({super.key, required Clinic clinic, required super.child})
      : super(notifier: clinic);

  static Clinic of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ClinicScope>()!.notifier!;
}
