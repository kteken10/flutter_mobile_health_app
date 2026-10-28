import 'package:flutter/material.dart';

import 'risk.dart';

class Category {
  const Category(this.name, this.icon, this.color);

  final String name;
  final IconData icon;
  final Color color;
}

enum ParamKind { number, toggle, choice }

/// Une donnée clinique saisie par le médecin.
class ClinicalParam {
  const ClinicalParam.number({
    required this.id,
    required this.label,
    required this.unit,
    required this.min,
    required this.max,
    required double initial,
    this.step = 1,
    this.hint,
  })  : kind = ParamKind.number,
        initialValue = initial,
        options = const [];

  const ClinicalParam.toggle({
    required this.id,
    required this.label,
    this.hint,
  })  : kind = ParamKind.toggle,
        unit = '',
        min = 0,
        max = 1,
        step = 1,
        initialValue = false,
        options = const [];

  const ClinicalParam.choice({
    required this.id,
    required this.label,
    required this.options,
    this.hint,
  })  : kind = ParamKind.choice,
        unit = '',
        min = 0,
        max = 0,
        step = 1,
        initialValue = 0;

  final String id;
  final String label;
  final ParamKind kind;
  final String unit;
  final double min;
  final double max;
  final double step;
  final Object initialValue;
  final List<String> options;
  final String? hint;

  int get decimals => step < 1 ? 1 : 0;

  String format(Object value) => switch (kind) {
        ParamKind.number =>
          '${(value as double).toStringAsFixed(decimals)}${unit.isEmpty ? '' : ' $unit'}',
        ParamKind.toggle => (value as bool) ? 'Oui' : 'Non',
        ParamKind.choice => options[value as int],
      };
}

/// Valeurs saisies, indexées par identifiant de paramètre.
typedef ClinicalValues = Map<String, Object>;

class Disease {
  const Disease({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.image,
    required this.summary,
    required this.params,
    required this.assess,
  });

  final String id;
  final String name;
  final Category category;
  final IconData icon;
  final String image;
  final String summary;
  final List<ClinicalParam> params;
  final RiskResult Function(ClinicalValues values) assess;

  ClinicalValues get defaults => {for (final p in params) p.id: p.initialValue};
}
