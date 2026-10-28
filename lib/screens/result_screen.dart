import 'package:flutter/material.dart';

import '../models/analysis.dart';
import '../services/email_service.dart';
import '../services/format.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.analysis});

  final Analysis analysis;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _sending = false;

  Future<void> _send() async {
    final messenger = ScaffoldMessenger.of(context);
    if (!EmailService.isConfigured) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Envoi d\'e-mail non configuré : voir SMTP_USER dans le README.'),
      ));
      return;
    }
    setState(() => _sending = true);
    try {
      await EmailService().sendResult(widget.analysis);
      messenger.showSnackBar(SnackBar(content: Text('Résultat envoyé à ${widget.analysis.patient.email}')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Échec de l\'envoi : $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.analysis;
    final r = a.result;
    final maxPoints = r.factors.isEmpty ? 1 : r.factors.first.points;

    return Scaffold(
      appBar: AppBar(title: const Text('Résultat')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Terminer'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _sending ? null : _send,
                  icon: _sending
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, size: 20),
                  label: const Text('Envoyer'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          AppCard(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              children: [
                RiskGauge(r),
                const SizedBox(height: 16),
                Text(a.disease.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('${a.patient.fullName} · ${formatDateTime(a.date)}',
                    style: const TextStyle(color: AppColors.muted)),
                if (r.note != null) ...[
                  const SizedBox(height: 12),
                  Pill(r.note!, color: AppColors.primaryDark, background: AppColors.primarySoft,
                      icon: Icons.calculate_outlined),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle('Facteurs déterminants'),
          AppCard(
            child: r.factors.isEmpty
                ? const Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, color: AppColors.low),
                      SizedBox(width: 12),
                      Expanded(child: Text('Aucun seuil de risque franchi.')),
                    ],
                  )
                : Column(
                    children: [
                      for (final (i, f) in r.factors.indexed) ...[
                        if (i > 0) const SizedBox(height: 16),
                        _FactorRow(f.label, f.detail, f.points, f.points / maxPoints, r.level.color),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: 24),
          const SectionTitle('Valeurs saisies'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              children: [
                for (final (i, p) in a.disease.params.indexed) ...[
                  if (i > 0) const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(child: Text(p.label, style: const TextStyle(color: AppColors.muted))),
                        Text(p.format(a.values[p.id]!), style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle('Conduite à tenir'),
          AppCard(
            child: Column(
              children: [
                for (final (i, text) in r.recommendations.indexed) ...[
                  if (i > 0) const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                        child: Text('${i + 1}',
                            style: const TextStyle(
                                color: AppColors.primaryDark, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: AppColors.muted),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Score indicatif calculé à partir de seuils cliniques de référence. '
                  'Il aide au dépistage et ne remplace pas un diagnostic.',
                  style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FactorRow extends StatelessWidget {
  const _FactorRow(this.label, this.detail, this.points, this.ratio, this.color);

  final String label;
  final String detail;
  final int points;
  final double ratio;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
            Text('+$points', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 3),
        Text(detail, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            color: color,
            backgroundColor: AppColors.line,
          ),
        ),
      ],
    );
  }
}
