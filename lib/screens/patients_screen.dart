import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/patient.dart';
import '../services/clinic.dart';
import '../theme.dart';
import '../widgets/add_patient_sheet.dart';
import '../widgets/common.dart';
import 'patient_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  String _query = '';
  PatientStatus? _status;

  @override
  Widget build(BuildContext context) {
    final clinic = ClinicScope.of(context);
    final patients = clinic.patients.where((p) {
      final matches = p.fullName.toLowerCase().contains(_query.toLowerCase());
      return matches && (_status == null || p.status == _status);
    }).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddPatientSheet(context),
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Nouveau patient', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Row(
              children: [
                const Avatar('CM', size: 46, photo: doctorPhoto),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bonjour,', style: TextStyle(color: AppColors.muted, fontSize: 14)),
                      Text(doctorName, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                    ],
                  ),
                ),
                IconButton.outlined(
                  onPressed: () {},
                  style: IconButton.styleFrom(side: const BorderSide(color: AppColors.line)),
                  icon: const Badge(
                    smallSize: 8,
                    backgroundColor: AppColors.high,
                    child: Icon(Icons.notifications_none_rounded, color: AppColors.ink),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _Overview(
              patients: clinic.patients.length,
              analyses: clinic.analyses.length,
              highRisk: clinic.highRiskCount,
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Rechercher un patient',
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.muted),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _filter('Tous', null),
                  for (final s in PatientStatus.values) _filter(s.label, s),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionTitle('Patients', trailing: Text('${patients.length}',
                style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600))),
            if (patients.isEmpty)
              const EmptyState(
                icon: Icons.person_search_rounded,
                title: 'Aucun patient',
                message: 'Aucun patient ne correspond à cette recherche.',
              ),
            for (final p in patients)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PatientTile(p),
              ),
          ],
        ),
      ),
    );
  }

  Widget _filter(String label, PatientStatus? status) {
    final selected = _status == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
        onSelected: (_) => setState(() => _status = status),
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.patients, required this.analyses, required this.highRisk});

  final int patients;
  final int analyses;
  final int highRisk;

  @override
  Widget build(BuildContext context) {
    Widget stat(String value, String label) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 13)),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Votre activité',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              stat('$patients', 'Patients'),
              stat('$analyses', 'Analyses'),
              stat('$highRisk', 'Risques élevés'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PatientTile extends StatelessWidget {
  const _PatientTile(this.patient);

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final latest = ClinicScope.of(context).latestOf(patient);
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PatientScreen(patient: patient)),
      ),
      child: Row(
        children: [
          Avatar.of(patient),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 3),
                Text(
                  latest == null
                      ? '${patient.age} ans · ${patient.sexLabel}'
                      : '${patient.age} ans · ${latest.disease.name}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusPill(patient.status),
        ],
      ),
    );
  }
}
