import 'disease.dart';
import 'patient.dart';
import 'risk.dart';

/// Une analyse réalisée pour un patient : valeurs saisies et résultat.
class Analysis {
  Analysis({
    required this.patient,
    required this.disease,
    required this.values,
    required this.date,
  }) : result = disease.assess(values);

  final Patient patient;
  final Disease disease;
  final ClinicalValues values;
  final DateTime date;
  final RiskResult result;
}
