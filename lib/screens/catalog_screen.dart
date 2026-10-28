import 'package:flutter/material.dart';

import '../data/diseases.dart';
import '../models/disease.dart';
import '../models/patient.dart';
import '../services/clinic.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'analysis_form_screen.dart';

/// Choix de l'analyse. Ouvert depuis un dossier, le patient est déjà connu ;
/// depuis l'onglet Analyse, il est choisi au moment de lancer.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, this.patient});

  final Patient? patient;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  Category? _category;
  String _query = '';
  late Patient? _patient = widget.patient;

  Future<void> _open(Disease disease) async {
    final patient = _patient ?? await _pickPatient();
    if (patient == null || !mounted) return;
    setState(() => _patient = patient);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AnalysisFormScreen(patient: patient, disease: disease)),
    );
  }

  Future<Patient?> _pickPatient() {
    final patients = ClinicScope.of(context).patients;
    return showModalBottomSheet<Patient>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            const Text('Choisir un patient', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            for (final p in patients)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  padding: const EdgeInsets.all(12),
                  onTap: () => Navigator.of(context).pop(p),
                  child: Row(
                    children: [
                      Avatar.of(p, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(p.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      Text('${p.age} ans', style: const TextStyle(color: AppColors.muted)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = diseases.where((d) {
      final inCategory = _category == null || d.category == _category;
      return inCategory && d.name.toLowerCase().contains(_query.toLowerCase());
    }).toList();
    final standalone = widget.patient == null;

    return Scaffold(
      appBar: standalone ? null : AppBar(title: const Text('Nouvelle analyse')),
      body: SafeArea(
        top: standalone,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, standalone ? 16 : 4, 20, 32),
          children: [
            if (standalone) ...[
              const Text('Nouvelle analyse',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              const SizedBox(height: 6),
              const Text('Choisissez une pathologie, saisissez les données cliniques et obtenez un score expliqué.',
                  style: TextStyle(color: AppColors.muted, height: 1.4)),
              const SizedBox(height: 20),
            ],
            _PatientCard(patient: _patient, onChange: () async {
              final p = await _pickPatient();
              if (p != null) setState(() => _patient = p);
            }),
            const SizedBox(height: 16),
            TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Rechercher une pathologie',
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.muted),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _chip('Toutes', null, null),
                  for (final c in categories) _chip(c.name, c, c.icon),
                ],
              ),
            ),
            const SizedBox(height: 20),
            for (final d in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DiseaseCard(d, onTap: () => _open(d)),
              ),
            if (list.isEmpty)
              const EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Aucune pathologie',
                message: 'Essayez un autre mot ou une autre catégorie.',
              ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Category? category, IconData? icon) {
    final selected = _category == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: icon == null
            ? null
            : Icon(icon, size: 16, color: selected ? Colors.white : category!.color),
        label: Text(label),
        selected: selected,
        labelStyle: TextStyle(color: selected ? Colors.white : AppColors.ink, fontWeight: FontWeight.w600),
        onSelected: (_) => setState(() => _category = category),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient, required this.onChange});

  final Patient? patient;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final p = patient;
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onChange,
      child: Row(
        children: [
          p == null
              ? const IconTile(Icons.person_outline_rounded, AppColors.primary)
              : Avatar.of(p, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Patient', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                const SizedBox(height: 2),
                Text(p == null ? 'Choisir un patient' : '${p.fullName} · ${p.age} ans',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ],
            ),
          ),
          Text(p == null ? 'Choisir' : 'Changer',
              style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DiseaseCard extends StatelessWidget {
  const _DiseaseCard(this.disease, {required this.onTap});

  final Disease disease;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          DiseaseArt(disease, size: 64),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(disease.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 4),
                Text(disease.summary, style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.35)),
                const SizedBox(height: 8),
                Text('${disease.category.name} · ${disease.params.length} paramètres',
                    style: TextStyle(color: disease.category.color, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}
