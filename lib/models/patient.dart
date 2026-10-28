enum Sex { female, male }

enum PatientStatus {
  followUp('Suivi'),
  treatment('En traitement'),
  stable('Stable'),
  critical('Critique');

  const PatientStatus(this.label);
  final String label;
}

class Patient {
  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.sex,
    required this.email,
    required this.phone,
    this.status = PatientStatus.followUp,
  });

  final String id;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final Sex sex;
  final String email;
  final String phone;
  final PatientStatus status;

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();
  String get sexLabel => sex == Sex.female ? 'Femme' : 'Homme';

  int get age {
    final now = DateTime.now();
    var years = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return years;
  }
}
