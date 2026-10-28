import 'package:flutter/material.dart';

import '../models/analysis.dart';
import '../models/risk.dart';
import '../services/clinic.dart';
import '../services/format.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  RiskLevel? _level;

  @override
  Widget build(BuildContext context) {
    final analyses = ClinicScope.of(context)
        .analyses
        .where((a) => _level == null || a.result.level == _level)
        .toList();

    // Regroupe par jour, dans l'ordre chronologique inverse.
    final groups = <String, List<Analysis>>{};
    for (final a in analyses) {
      groups.putIfAbsent(formatDay(a.date), () => []).add(a);
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const Text('Historique', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 6),
            const Text('Toutes les analyses réalisées, de la plus récente à la plus ancienne.',
                style: TextStyle(color: AppColors.muted, height: 1.4)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<RiskLevel?>(
                segments: const [
                  ButtonSegment(value: null, label: Text('Toutes')),
                  ButtonSegment(value: RiskLevel.high, label: Text('Élevé')),
                  ButtonSegment(value: RiskLevel.moderate, label: Text('Modéré')),
                  ButtonSegment(value: RiskLevel.low, label: Text('Faible')),
                ],
                selected: {_level},
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  selectedBackgroundColor: AppColors.ink,
                  selectedForegroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.line),
                ),
                onSelectionChanged: (s) => setState(() => _level = s.first),
              ),
            ),
            const SizedBox(height: 8),
            if (analyses.isEmpty)
              const EmptyState(
                icon: Icons.history_rounded,
                title: 'Aucune analyse',
                message: 'Aucune analyse ne correspond à ce filtre.',
              ),
            for (final entry in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 10),
                child: Text(entry.key.toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
              ),
              for (final a in entry.value)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AnalysisTile(
                    a,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ResultScreen(analysis: a)),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
