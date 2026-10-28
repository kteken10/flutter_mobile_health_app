import 'package:flutter/material.dart';

import '../models/patient.dart';
import '../services/clinic.dart';
import '../services/format.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'catalog_screen.dart';
import 'result_screen.dart';

class PatientScreen extends StatelessWidget {
  const PatientScreen({super.key, required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final analyses = ClinicScope.of(context).analysesOf(patient);

    return Scaffold(
      appBar: AppBar(title: const Text('Dossier patient')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Avatar.of(patient, size: 60),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(patient.fullName,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('${patient.age} ans · ${patient.sexLabel}',
                              style: const TextStyle(color: AppColors.muted)),
                        ],
                      ),
                    ),
                    StatusPill(patient.status),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 14),
                _InfoRow(Icons.cake_outlined, 'Naissance', formatDate(patient.birthDate)),
                _InfoRow(Icons.mail_outline_rounded, 'E-mail', patient.email),
                _InfoRow(Icons.phone_outlined, 'Téléphone', patient.phone),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CatalogScreen(patient: patient)),
            ),
            icon: const Icon(Icons.biotech_rounded),
            label: const Text('Nouvelle analyse'),
          ),
          const SizedBox(height: 28),
          SectionTitle('Analyses', trailing: Text('${analyses.length}',
              style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600))),
          if (analyses.isEmpty)
            const EmptyState(
              icon: Icons.science_outlined,
              title: 'Aucune analyse',
              message: 'Lancez une première analyse pour ce patient.',
            ),
          for (final a in analyses)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AnalysisTile(
                a,
                showPatient: false,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ResultScreen(analysis: a)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.muted),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
