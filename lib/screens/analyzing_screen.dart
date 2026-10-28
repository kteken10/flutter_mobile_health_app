import 'package:flutter/material.dart';

import '../models/analysis.dart';
import '../theme.dart';
import 'result_screen.dart';

/// Transition entre la saisie et le résultat : les étapes du calcul défilent.
class AnalyzingScreen extends StatefulWidget {
  const AnalyzingScreen({super.key, required this.analysis});

  final Analysis analysis;

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> with SingleTickerProviderStateMixin {
  static const _steps = [
    'Vérification des valeurs saisies',
    'Comparaison aux seuils cliniques',
    'Calcul du score de risque',
  ];

  late final _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
    ..repeat(reverse: true);
  int _done = 0;

  @override
  void initState() {
    super.initState();
    _advance();
  }

  Future<void> _advance() async {
    for (var i = 0; i < _steps.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() => _done = i + 1);
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ResultScreen(analysis: widget.analysis)),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.analysis.disease;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) {
                  final t = Curves.easeInOut.transform(_pulse.value);
                  return Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.06 + 0.06 * t),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 104 + 8 * t,
                      height: 104 + 8 * t,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.14),
                      ),
                      alignment: Alignment.center,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 92,
                  height: 92,
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  child: Image.asset('assets/images/robot.png'),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Analyse en cours', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('${d.name} · ${widget.analysis.patient.fullName}',
                  textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 32),
              for (final (i, step) in _steps.indexed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: i < _done
                            ? const Icon(Icons.check_circle_rounded, key: ValueKey(1), color: AppColors.primary)
                            : i == _done
                                ? const SizedBox(
                                    key: ValueKey(2),
                                    width: 24,
                                    height: 24,
                                    child: Padding(
                                      padding: EdgeInsets.all(3),
                                      child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
                                    ),
                                  )
                                : const Icon(Icons.radio_button_unchecked_rounded,
                                    key: ValueKey(3), color: AppColors.line),
                      ),
                      const SizedBox(width: 12),
                      Text(step,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: i <= _done ? AppColors.ink : AppColors.muted,
                          )),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
