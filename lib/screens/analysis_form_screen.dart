import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/analysis.dart';
import '../models/disease.dart';
import '../models/patient.dart';
import '../services/clinic.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'analyzing_screen.dart';

class AnalysisFormScreen extends StatefulWidget {
  const AnalysisFormScreen({super.key, required this.patient, required this.disease});

  final Patient patient;
  final Disease disease;

  @override
  State<AnalysisFormScreen> createState() => _AnalysisFormScreenState();
}

class _AnalysisFormScreenState extends State<AnalysisFormScreen> {
  late final ClinicalValues _values = _initialValues();

  // Préremplit l'âge et le sexe à partir du dossier.
  ClinicalValues _initialValues() {
    final values = widget.disease.defaults;
    if (values.containsKey('age')) values['age'] = widget.patient.age.toDouble();
    if (values.containsKey('sex')) values['sex'] = widget.patient.sex == Sex.male ? 1 : 0;
    return values;
  }

  void _run() {
    final analysis = Analysis(
      patient: widget.patient,
      disease: widget.disease,
      values: Map.of(_values),
      date: DateTime.now(),
    );
    ClinicScope.of(context).addAnalysis(analysis);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => AnalyzingScreen(analysis: analysis),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.disease;
    return Scaffold(
      appBar: AppBar(title: Text(d.name)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton.icon(
            onPressed: _run,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('Lancer l\'analyse'),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        children: [
          AppCard(
            child: Row(
              children: [
                IconTile(d.icon, d.category.color, size: 52),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.category.name,
                          style: TextStyle(color: d.category.color, fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(d.summary, style: const TextStyle(height: 1.35)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Avatar(widget.patient.initials, size: 32),
              const SizedBox(width: 10),
              Text('${widget.patient.fullName} · ${widget.patient.age} ans',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 24),
          const SectionTitle('Données cliniques'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (i, p) in d.params.indexed) ...[
                  if (i > 0) const Divider(indent: 16, endIndent: 16),
                  _ParamRow(
                    param: p,
                    value: _values[p.id]!,
                    onChanged: (v) => setState(() => _values[p.id] = v),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParamRow extends StatelessWidget {
  const _ParamRow({required this.param, required this.value, required this.onChanged});

  final ClinicalParam param;
  final Object value;
  final ValueChanged<Object> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(param.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        if (param.hint != null || param.unit.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(param.hint ?? param.unit, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
        ],
      ],
    );

    final control = switch (param.kind) {
      ParamKind.number => _Stepper(param: param, value: value as double, onChanged: onChanged),
      ParamKind.toggle => Switch(
          value: value as bool,
          onChanged: onChanged,
        ),
      ParamKind.choice => SegmentedButton<int>(
          segments: [
            for (final (i, o) in param.options.indexed) ButtonSegment(value: i, label: Text(o)),
          ],
          selected: {value as int},
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
          onSelectionChanged: (s) => onChanged(s.first),
        ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(child: label),
          const SizedBox(width: 12),
          control,
        ],
      ),
    );
  }
}

class _Stepper extends StatefulWidget {
  const _Stepper({required this.param, required this.value, required this.onChanged});

  final ClinicalParam param;
  final double value;
  final ValueChanged<Object> onChanged;

  @override
  State<_Stepper> createState() => _StepperState();
}

class _StepperState extends State<_Stepper> {
  late final _controller = TextEditingController(text: _text(widget.value));
  final _focus = FocusNode();

  String _text(double v) => v.toStringAsFixed(widget.param.decimals);

  @override
  void initState() {
    super.initState();
    // La valeur est sélectionnée à l'entrée dans le champ : la saisie la remplace.
    _focus.addListener(() {
      if (_focus.hasFocus) {
        _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
      }
    });
  }

  @override
  void didUpdateWidget(_Stepper old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && _controller.text != _text(widget.value)) {
      _controller.text = _text(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _set(double v) {
    final p = widget.param;
    final clamped = double.parse(v.clamp(p.min, p.max).toStringAsFixed(p.decimals));
    _controller.text = _text(clamped);
    widget.onChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.param;
    Widget button(IconData icon, double delta) => SizedBox(
          width: 34,
          height: 34,
          child: IconButton.filledTonal(
            padding: EdgeInsets.zero,
            iconSize: 18,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.ink,
            ),
            onPressed: () => _set(widget.value + delta),
            icon: Icon(icon),
          ),
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(Icons.remove_rounded, -p.step),
        SizedBox(
          width: 64,
          child: TextField(
            controller: _controller,
            focusNode: _focus,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            decoration: const InputDecoration(
              isDense: true,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            onSubmitted: (t) => _set(double.tryParse(t.replaceAll(',', '.')) ?? widget.value),
            onTapOutside: (_) {
              if (!_focus.hasFocus) return;
              _focus.unfocus();
              _set(double.tryParse(_controller.text.replaceAll(',', '.')) ?? widget.value);
            },
          ),
        ),
        button(Icons.add_rounded, p.step),
      ],
    );
  }
}
