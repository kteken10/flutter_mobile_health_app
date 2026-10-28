import 'package:flutter/material.dart';

import '../theme.dart';

enum RiskLevel {
  low('Risque faible', AppColors.low, AppColors.lowSoft),
  moderate('Risque modéré', AppColors.moderate, AppColors.moderateSoft),
  high('Risque élevé', AppColors.high, AppColors.highSoft);

  const RiskLevel(this.label, this.color, this.softColor);
  final String label;
  final Color color;
  final Color softColor;

  String get shortLabel => switch (this) {
        RiskLevel.low => 'Faible',
        RiskLevel.moderate => 'Modéré',
        RiskLevel.high => 'Élevé',
      };

  static RiskLevel fromScore(double score) => score >= 0.6
      ? RiskLevel.high
      : score >= 0.3
          ? RiskLevel.moderate
          : RiskLevel.low;
}

/// Un élément qui fait monter le score, avec le seuil clinique franchi.
class RiskFactor {
  const RiskFactor(this.label, this.detail, this.points);

  final String label;
  final String detail;
  final int points;
}

class RiskResult {
  RiskResult({
    required List<RiskFactor> factors,
    required this.recommendations,
    this.note,
  })  : factors = [...factors]..sort((a, b) => b.points.compareTo(a.points)),
        score = (factors.fold<int>(0, (s, f) => s + f.points) / 100)
            .clamp(0.0, 1.0)
            .toDouble();

  final List<RiskFactor> factors;
  final double score;
  final List<String> recommendations;

  /// Valeur calculée affichée avec le résultat (IMC par exemple).
  final String? note;

  RiskLevel get level => RiskLevel.fromScore(score);
  int get percent => (score * 100).round();
}
