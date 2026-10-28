import 'package:flutter/material.dart';

import '../models/patient.dart';
import '../services/clinic.dart';
import '../services/format.dart';
import '../theme.dart';

Future<void> showAddPatientSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => const _AddPatientSheet(),
  );
}

class _AddPatientSheet extends StatefulWidget {
  const _AddPatientSheet();

  @override
  State<_AddPatientSheet> createState() => _AddPatientSheetState();
}

class _AddPatientSheetState extends State<_AddPatientSheet> {
  final _form = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  DateTime? _birthDate;
  Sex _sex = Sex.female;

  @override
  void dispose() {
    for (final c in [_firstName, _lastName, _email, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1985),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _birthDate = date);
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indiquez la date de naissance.')),
      );
      return;
    }
    final patient = Patient(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      birthDate: _birthDate!,
      sex: _sex,
      email: _email.text.trim(),
      phone: _phone.text.trim(),
    );
    ClinicScope.of(context).addPatient(patient);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text('${patient.fullName} a été ajouté.')));
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Nouveau patient', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Ces informations restent sur l\'appareil.', style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstName,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Prénom'),
                      validator: _required,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastName,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Nom'),
                      validator: _required,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date de naissance',
                    suffixIcon: Icon(Icons.calendar_today_outlined, size: 20),
                  ),
                  child: Text(_birthDate == null ? 'Choisir' : formatDate(_birthDate!)),
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<Sex>(
                segments: const [
                  ButtonSegment(value: Sex.female, label: Text('Femme')),
                  ButtonSegment(value: Sex.male, label: Text('Homme')),
                ],
                selected: {_sex},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _sex = s.first),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.mail_outline_rounded)),
                validator: (v) => (v != null && v.contains('@')) ? null : 'E-mail invalide',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Téléphone', prefixIcon: Icon(Icons.phone_outlined)),
                validator: _required,
              ),
              const SizedBox(height: 20),
              FilledButton(onPressed: _save, child: const Text('Ajouter le patient')),
            ],
          ),
        ),
      ),
    );
  }
}
