import '../models/analysis.dart';
import '../models/patient.dart';
import 'diseases.dart';

// Données fictives de démonstration.

const doctorName = 'Dr Claire Mbarga';
const doctorSpecialty = 'Médecine générale';
const clinicName = 'Clinique du Lac, Douala';

const doctorPhoto = 'assets/images/doctor-avatar.png';

final samplePatients = [
  Patient(id: 'p1', firstName: 'David', lastName: 'Ekoto', birthDate: DateTime(1984, 5, 4), sex: Sex.male, email: 'david.ekoto@example.com', phone: '+237 6 77 21 45 10', status: PatientStatus.treatment, photo: 'assets/images/patients/p1.jpg'),
  Patient(id: 'p2', firstName: 'Emmanuel', lastName: 'Ngouo', birthDate: DateTime(1966, 8, 22), sex: Sex.male, email: 'e.ngouo@example.com', phone: '+237 6 99 04 18 72', status: PatientStatus.critical),
  Patient(id: 'p3', firstName: 'Léa', lastName: 'Martin', birthDate: DateTime(1990, 11, 9), sex: Sex.female, email: 'lea.martin@example.com', phone: '+237 6 55 63 02 91', status: PatientStatus.stable, photo: 'assets/images/patients/p3.jpg'),
  Patient(id: 'p4', firstName: 'Yannick', lastName: 'Fotso', birthDate: DateTime(1997, 2, 21), sex: Sex.male, email: 'yannick.fotso@example.com', phone: '+237 6 70 88 13 26', photo: 'assets/images/patients/p4.jpg'),
  Patient(id: 'p5', firstName: 'Fatou', lastName: 'Ndiaye', birthDate: DateTime(1988, 2, 17), sex: Sex.female, email: 'fatou.ndiaye@example.com', phone: '+237 6 94 37 50 08', status: PatientStatus.treatment),
  Patient(id: 'p6', firstName: 'Marc', lastName: 'Lefèvre', birthDate: DateTime(1972, 7, 23), sex: Sex.male, email: 'marc.lefevre@example.com', phone: '+237 6 51 72 66 40', status: PatientStatus.stable, photo: 'assets/images/patients/p6.jpg'),
  Patient(id: 'p7', firstName: 'Inès', lastName: 'Moreau', birthDate: DateTime(1995, 12, 12), sex: Sex.female, email: 'ines.moreau@example.com', phone: '+237 6 80 19 24 57', photo: 'assets/images/patients/p7.jpg'),
];

List<Analysis> sampleAnalyses() {
  final now = DateTime.now();
  final p = {for (final x in samplePatients) x.id: x};
  DateTime ago(int days, int hour, int minute) =>
      DateTime(now.year, now.month, now.day - days, hour, minute);
  // Analyses du jour : quelques heures avant l'ouverture de l'app.
  DateTime earlier(int minutes) => now.subtract(Duration(minutes: minutes));

  return [
    Analysis(patient: p['p2']!, disease: hypertension, date: earlier(55), values: {'sbp': 162.0, 'dbp': 98.0, 'hr': 88.0, 'chol': 246.0, 'age': 60.0, 'smoker': true}),
    Analysis(patient: p['p1']!, disease: diabetes, date: earlier(100), values: {'glucose': 118.0, 'hba1c': 6.1, 'bmi': 29.4, 'age': 42.0, 'dbp': 84.0, 'family': true, 'sedentary': false}),
    Analysis(patient: p['p5']!, disease: anemia, date: ago(1, 16, 5), values: {'hb': 10.4, 'sex': 0, 'hr': 96.0, 'fatigue': true, 'pallor': true}),
    Analysis(patient: p['p3']!, disease: covid, date: ago(1, 11, 30), values: {'temp': 37.2, 'spo2': 98.0, 'cough': true, 'dyspnea': false, 'anosmia': false, 'contact': false}),
    Analysis(patient: p['p6']!, disease: obesity, date: ago(3, 14, 20), values: {'weight': 96.0, 'height': 174.0, 'waist': 108.0, 'sex': 1}),
    Analysis(patient: p['p1']!, disease: hypertension, date: ago(21, 15, 0), values: {'sbp': 134.0, 'dbp': 86.0, 'hr': 76.0, 'chol': 205.0, 'age': 42.0, 'smoker': false}),
    Analysis(patient: p['p1']!, disease: diabetes, date: ago(92, 9, 30), values: {'glucose': 98.0, 'hba1c': 5.6, 'bmi': 29.9, 'age': 42.0, 'dbp': 82.0, 'family': true, 'sedentary': false}),
    Analysis(patient: p['p4']!, disease: diabetes, date: ago(5, 10, 15), values: {'glucose': 92.0, 'hba1c': 5.3, 'bmi': 23.8, 'age': 29.0, 'dbp': 76.0, 'family': false, 'sedentary': true}),
  ];
}
